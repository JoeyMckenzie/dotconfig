{ ... }:

{
  # Disable built-in netrw so it doesn't hijack directory buffers on launch —
  # otherwise `nvim .` lands in netrw's listing before our VimEnter autocmd
  # can open mini.starter. mini.files is the explorer we actually want.
  programs.nixvim.globals = {
    loaded_netrw = 1;
    loaded_netrwPlugin = 1;
  };

  # mini.starter's built-in autoopen only fires when nvim is launched with no
  # args. For `nvim .` we open it explicitly after wiping the directory buffer
  # that nvim creates for the dir arg. The MiniIndentscopeDisable autocmd
  # suppresses the indent-scope guide in non-code filetypes (starter, files,
  # help, etc.) — mirrors the old indent-blankline exclude list.
  programs.nixvim.extraConfigLua = ''
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("StarterOnDirArg", { clear = true }),
      callback = function()
        if vim.fn.argc() ~= 1 then return end
        local arg = vim.fn.argv(0)
        if vim.fn.isdirectory(arg) ~= 1 then return end

        vim.schedule(function()
          pcall(require("mini.starter").open)
        end)
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("MiniIndentscopeDisable", { clear = true }),
      pattern = {
        "ministarter", "minifiles", "help", "lazy", "mason", "notify",
        "lspinfo", "checkhealth", "man", "gitcommit",
        "neotest-output", "neotest-output-panel", "neotest-summary",
        "dap-repl", "dapui_scopes", "dapui_breakpoints", "dapui_stacks",
        "dapui_watches", "dapui_console", "",
      },
      callback = function() vim.b.miniindentscope_disable = true end,
    })
  '';

  # Route vim.notify through mini.notify so LSP / plugin notifications render
  # in floating windows, and route vim.ui.select (used by code actions, etc.)
  # through mini.pick. Must run after the respective setup() calls, hence Post.
  # (The nvim-web-devicons shim is wired up via plugins.mini.mockDevIcons below.)
  programs.nixvim.extraConfigLuaPost = ''
    vim.notify = require("mini.notify").make_notify()
    vim.ui.select = MiniPick.ui_select

    -- Dim gitignored entries in mini.files. Overrides `content.highlight`
    -- (the function mini.files calls per-entry to pick a highlight group)
    -- so ignored entries render with MiniFilesIgnored instead of fighting
    -- mini's own name extmarks. Results are cached per directory, so we
    -- only shell out to `git check-ignore` once per directory entered.
    -- Swap the link target (e.g. NonText) if Comment isn't dim enough.
    vim.api.nvim_set_hl(0, "MiniFilesIgnored", { link = "Comment", default = true })

    local ignored_cache = {}

    local function ignored_set(dir)
      if ignored_cache[dir] ~= nil then return ignored_cache[dir] end
      local ok, entries = pcall(vim.fn.readdir, dir)
      if not ok or #entries == 0 then
        ignored_cache[dir] = false
        return false
      end
      local out = vim.fn.system(
        { "git", "-C", dir, "check-ignore", "--stdin" },
        table.concat(entries, "\n")
      )
      -- exit 0: some ignored, 1: none ignored, anything else (128) =
      -- not a git repo / error -> bail and cache the miss.
      if vim.v.shell_error ~= 0 and vim.v.shell_error ~= 1 then
        ignored_cache[dir] = false
        return false
      end
      local set = {}
      for name in out:gmatch("[^\r\n]+") do set[name] = true end
      ignored_cache[dir] = set
      return set
    end

    MiniFiles.config.content = MiniFiles.config.content or {}
    MiniFiles.config.content.highlight = function(fs_entry)
      local set = ignored_set(vim.fn.fnamemodify(fs_entry.path, ":h"))
      if set and set[fs_entry.name] then return "MiniFilesIgnored" end
      return MiniFiles.default_highlight(fs_entry)
    end

    -- Invalidate the cache when mini.files mutates the filesystem.
    vim.api.nvim_create_autocmd("User", {
      group = vim.api.nvim_create_augroup("MiniFilesGitignoreCache", { clear = true }),
      pattern = {
        "MiniFilesActionCreate", "MiniFilesActionDelete",
        "MiniFilesActionRename", "MiniFilesActionMove", "MiniFilesActionCopy",
      },
      callback = function() ignored_cache = {} end,
    })
  '';

  programs.nixvim.plugins = {
    # todo-comments has no mini equivalent — highlights TODO/FIXME/HACK and
    # provides :TodoTelescope-style listing (we use mini.pick for that now,
    # via require("todo-comments.fzf") fallbacks aren't needed).
    todo-comments.enable = true;

    mini = {
      enable = true;
      # Register mini.icons as the nvim-web-devicons provider. Keeps any
      # plugin that still requires nvim-web-devicons happy (and prevents
      # NixVim from auto-enabling the standalone plugins.web-devicons).
      mockDevIcons = true;
      modules = {
        # Icon provider. mini.tabline / mini.files / mini.pick consume it
        # directly; anything that asks for nvim-web-devicons gets the shim
        # via mockDevIcons.
        icons = { };

        # Miller-columns file explorer. Open with <leader>e (see keymaps.nix)
        # or from the mini.starter "File explorer" item. Edit the buffer like
        # text to rename/move/delete/create, then :write to sync.
        #
        # use_as_default_explorer = false so `nvim <dir>` doesn't hijack the
        # directory buffer — we want mini.starter to render via the
        # StarterOnDirArg autocmd above. Set to true if you'd rather land
        # straight in the explorer when launching with a dir arg.
        files = {
          windows.preview = true;
          mappings.go_in_plus = "<CR>";
          options.use_as_default_explorer = false;
        };

        # Floating-window notifications. vim.notify is rerouted in
        # extraConfigLuaPost so LSP / plugin messages render here instead of
        # the default :messages echo.
        notify = {
          lsp_progress.enable = true;
          window.winblend = 0;
        };

        # Fuzzy picker (files, live grep, buffers, help, ...). Uses rg / fd /
        # git ls-files automatically when present. vim.ui.select is rerouted
        # to MiniPick.ui_select in extraConfigLuaPost so LSP code actions and
        # other selection prompts go through it too.
        pick = {
          mappings = {
            move_down = "<C-j>";
            move_up = "<C-k>";
          };
        };

        # Extra pickers built on top of mini.pick: oldfiles, lsp (with
        # scope=document_symbol / workspace_symbol / references / etc.),
        # diagnostic, git_*, keymaps, marks, registers, treesitter, ...
        # Accessed via MiniExtra.pickers.<name>().
        extra = { };

        # gcc to toggle line, gc{motion} for operator-pending. Replaces
        # numToStr/Comment.nvim.
        comment = { };

        # Auto-insert closing brackets/quotes. Replaces nvim-autopairs.
        pairs = { };

        # sa{motion}{char} add, sd{char} delete, sr{old}{new} replace,
        # sf/sF find, sh highlight, sn change n_lines. Operates on the
        # `s` key prefix in normal mode (overrides built-in substitute,
        # which is rarely used — use `cl` instead).
        surround = { };

        # Smarter text objects. Adds aq/iq (any quote), ab/ib (any
        # bracket), af/if (function), aa/ia (argument), plus
        # last/next variants (an(, il{, etc.).
        ai = { };

        # vim-unimpaired-style ]X / [X navigation. Provides ]b/[b
        # (buffers), ]q/[q (quickfix), ]d/[d (diagnostics — overlaps
        # our custom keymaps, mini's wins), ]j/[j (jumplist), ]c/[c
        # (changelist), and ~15 more.
        bracketed = { };

        # Alt-h/j/k/l to move the current line (normal) or selection
        # (visual). Indentation is preserved.
        move = { };

        # `:bdelete` replacement that keeps your window layout intact
        # when deleting the last buffer in a window. Bound to <leader>bd
        # in keymaps.nix.
        bufremove = { };

        # Replaces folke/which-key. Pops up a list of follow-up keys
        # after a prefix. `gen_clues.*` adds nicely-labelled entries for
        # built-in things (g-prefixed cmds, marks, registers, windows,
        # z-folds, completion). Your own keymaps' `desc` fields show up
        # automatically.
        clue = {
          triggers = [
            {
              mode = "n";
              keys = "<Leader>";
            }
            {
              mode = "x";
              keys = "<Leader>";
            }
            {
              mode = "i";
              keys = "<C-x>";
            }
            {
              mode = "n";
              keys = "g";
            }
            {
              mode = "x";
              keys = "g";
            }
            {
              mode = "n";
              keys = "'";
            }
            {
              mode = "n";
              keys = "`";
            }
            {
              mode = "x";
              keys = "'";
            }
            {
              mode = "x";
              keys = "`";
            }
            {
              mode = "n";
              keys = "\"";
            }
            {
              mode = "x";
              keys = "\"";
            }
            {
              mode = "i";
              keys = "<C-r>";
            }
            {
              mode = "c";
              keys = "<C-r>";
            }
            {
              mode = "n";
              keys = "<C-w>";
            }
            {
              mode = "n";
              keys = "z";
            }
            {
              mode = "x";
              keys = "z";
            }
          ];
          clues.__raw = ''
            {
              require("mini.clue").gen_clues.builtin_completion(),
              require("mini.clue").gen_clues.g(),
              require("mini.clue").gen_clues.marks(),
              require("mini.clue").gen_clues.registers(),
              require("mini.clue").gen_clues.windows(),
              require("mini.clue").gen_clues.z(),
            }
          '';
        };

        # Replaces indent-blankline. Shows an animated guide for the
        # *current* indent scope (not every level). Disabled for special
        # filetypes via the MiniIndentscopeDisable autocmd in
        # extraConfigLua above.
        indentscope = {
          symbol = "│";
          options.try_as_border = true;
        };

        # Replaces akinsho/bufferline. Buffer list along the top with
        # mini.icons-driven filetype icons.
        tabline = { };

        # Replaces nvim-lualine. Mode / git branch / diagnostics /
        # filename / cursor pos. Plainer than lualine but coherent with
        # the rest of mini.
        statusline = { };

        # Replaces lewis6991/gitsigns. Shows hunk signs in the gutter,
        # provides `gh` text object + apply/reset operators, and
        # `[h`/`]h` to jump between hunks (also via mini.bracketed).
        diff = {
          view.signs = {
            add = "│";
            change = "│";
            delete = "_";
          };
        };

        # Git wrapper — adds :Git command and tracks repo state for
        # mini.statusline's branch component. Current-line blame via
        # `MiniGit.show_at_cursor()`.
        git = { };

        # Startup screen — opens automatically when nvim is launched without
        # args. Day-of-week banner + a small action menu. Navigate with arrow
        # keys (or <C-n>/<C-p>) and <CR>, or type any substring of an item
        # name + <CR> (evaluate_single makes that unambiguous).
        starter = {
          autoopen = true;
          evaluate_single = true;
          header.__raw = ''
                        (function()
                          local banners = {
                            Monday = [[
             __  __  ____  _   _ _____      __     __
            |  \/  |/ __ \| \ | |  __ \   /\\ \   / /
            | \  / | |  | |  \| | |  | | /  \\ \_/ /
            | |\/| | |  | | . ` | |  | |/ /\ \\   /
            | |  | | |__| | |\  | |__| / ____ \| |
            |_|  |_|\____/|_| \_|_____/_/    \_\_|
            ]],
                            Tuesday = [[
             _______ _    _ ______  _____ _____      __     __
            |__   __| |  | |  ____|/ ____|  __ \   /\\ \   / /
               | |  | |  | | |__  | (___ | |  | | /  \\ \_/ /
               | |  | |  | |  __|  \___ \| |  | |/ /\ \\   /
               | |  | |__| | |____ ____) | |__| / ____ \| |
               |_|   \____/|______|_____/|_____/_/    \_\_|
            ]],
                            Wednesday = [[
            __          ________ _____  _   _ ______  _____ _____      __     __
            \ \        / /  ____|  __ \| \ | |  ____|/ ____|  __ \   /\\ \   / /
             \ \  /\  / /| |__  | |  | |  \| | |__  | (___ | |  | | /  \\ \_/ /
              \ \/  \/ / |  __| | |  | | . ` |  __|  \___ \| |  | |/ /\ \\   /
               \  /\  /  | |____| |__| | |\  | |____ ____) | |__| / ____ \| |
                \/  \/   |______|_____/|_| \_|______|_____/|_____/_/    \_\_|
            ]],
                            Thursday = [[
             _______ _    _ _    _ _____   _____ _____      __     __
            |__   __| |  | | |  | |  __ \ / ____|  __ \   /\\ \   / /
               | |  | |__| | |  | | |__) | (___ | |  | | /  \\ \_/ /
               | |  |  __  | |  | |  _  / \___ \| |  | |/ /\ \\   /
               | |  | |  | | |__| | | \ \ ____) | |__| / ____ \| |
               |_|  |_|  |_|\____/|_|  \_\_____/|_____/_/    \_\_|
            ]],
                            Friday = [[
             ______ _____  _____ _____      __     __
            |  ____|  __ \|_   _|  __ \   /\\ \   / /
            | |__  | |__) | | | | |  | | /  \\ \_/ /
            |  __| |  _  /  | | | |  | |/ /\ \\   /
            | |    | | \ \ _| |_| |__| / ____ \| |
            |_|    |_|  \_\_____|_____/_/    \_\_|
            ]],
                            Saturday = [[
              _____      _______ _    _ _____  _____      __     __
             / ____|  /\|__   __| |  | |  __ \|  __ \   /\\ \   / /
            | (___   /  \  | |  | |  | | |__) | |  | | /  \\ \_/ /
             \___ \ / /\ \ | |  | |  | |  _  /| |  | |/ /\ \\   /
             ____) / ____ \| |  | |__| | | \ \| |__| / ____ \| |
            |_____/_/    \_\_|   \____/|_|  \_\_____/_/    \_\_|
            ]],
                            Sunday = [[
              _____ _    _ _   _ _____      __     __
             / ____| |  | | \ | |  __ \   /\\ \   / /
            | (___ | |  | |  \| | |  | | /  \\ \_/ /
             \___ \| |  | | . ` | |  | |/ /\ \\   /
             ____) | |__| | |\  | |__| / ____ \| |
            |_____/ \____/|_| \_|_____/_/    \_\_|
            ]],
                          }
                          local logo = banners[os.date("%A")] or ""
                          local raw = vim.split(logo, "\n")
                          while #raw > 0 and raw[#raw] == "" do
                            table.remove(raw)
                          end
                          while #raw > 0 and raw[1] == "" do
                            table.remove(raw, 1)
                          end
                          local max_w = 0
                          for _, line in ipairs(raw) do
                            if #line > max_w then max_w = #line end
                          end
                          local lines = {}
                          for _, line in ipairs(raw) do
                            table.insert(lines, line .. string.rep(" ", max_w - #line))
                          end
                          table.insert(lines, "")
                          table.insert(lines, os.date("%B %d, %Y"))
                          return table.concat(lines, "\n")
                        end)
          '';
          footer.__raw = ''
                        (function()
                          math.randomseed(os.time())
                          local quotes = {
                            { "Austin 3:16 says... I just whooped your ass!", "Stone Cold" },
                            { "And that's the bottom line, 'cause Stone Cold said so!", "Stone Cold" },
                            { "If you smell what The Rock is cookin'!", "The Rock" },
                            { "It doesn't matter what you think!", "The Rock" },
                            { "Know your role and shut your mouth!", "The Rock" },
                            { "Whatcha gonna do, brother, when Hulkamania runs wild on you?!", "Hulk Hogan" },
                            { "To be the man, you gotta beat the man! Wooo!", "Ric Flair" },
                            { "Oooh yeah, dig it!", "Macho Man Randy Savage" },
                            { "The cream rises to the top!", "Macho Man Randy Savage" },
                            { "Rest in peace.", "The Undertaker" },
                            { "Are you ready?!", "Triple H" },
                            { "It's time to play the game!", "Triple H" },
                            { "Have a nice day!", "Mick Foley" },
                            { "I lie, I cheat, I steal!", "Eddie Guerrero" },
                            { "Bah Gawd! Business is about to pick up!", "Jim Ross" },
                            { "The best in the world.", "CM Punk" },
                            { "The best there is, the best there was, and the best there ever will be.", "Bret Hart" },
                            { "You can't see me!", "John Cena" },
                            { "Nobody does it better than Mr. Perfect.", "Mr. Perfect" },
                          }
                          local q = quotes[math.random(#quotes)]
                          return '"' .. q[1] .. '" — ' .. q[2]
                        end)
          '';
          items = [
            {
              name = "Find files";
              action = "lua MiniPick.builtin.files()";
              section = "Pick";
            }
            {
              name = "Recent files";
              action = "lua MiniExtra.pickers.oldfiles()";
              section = "Pick";
            }
            {
              name = "Live grep";
              action = "lua MiniPick.builtin.grep_live()";
              section = "Pick";
            }
            {
              name = "New file";
              action = "ene | startinsert";
              section = "Builtin";
            }
            {
              name = "File explorer";
              action = "lua MiniFiles.open()";
              section = "Builtin";
            }
            {
              name = "Config";
              action = "edit ~/.config/nix-darwin/home/neovim/default.nix";
              section = "Builtin";
            }
            {
              name = "Quit";
              action = "qa";
              section = "Builtin";
            }
          ];
          content_hooks.__raw = ''
            {
              require("mini.starter").gen_hook.adding_bullet(),
              require("mini.starter").gen_hook.aligning("center", "center"),
            }
          '';
        };
      };
    };
  };
}
