{ ... }:

{
  # Disable built-in netrw so it doesn't hijack directory buffers on launch —
  # otherwise `nvim .` lands in netrw's listing before our VimEnter autocmd
  # can open mini.starter. neo-tree provides the file tree we actually want.
  programs.nixvim.globals = {
    loaded_netrw = 1;
    loaded_netrwPlugin = 1;
  };

  # mini.starter's built-in autoopen only fires when nvim is launched with no
  # args. For `nvim .` we open it explicitly after wiping the directory buffer
  # that nvim creates for the dir arg.
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
  '';

  # Route vim.notify through mini.notify so LSP / plugin notifications render
  # in floating windows. Must run after mini.notify.setup(), hence Post.
  programs.nixvim.extraConfigLuaPost = ''
    vim.notify = require("mini.notify").make_notify()
  '';

  programs.nixvim.plugins = {
    web-devicons.enable = true;

    lualine = {
      enable = true;
      settings = {
        options = {
          theme = "tokyonight";
          globalstatus = true;
          section_separators = {
            left = "";
            right = "";
          };
          component_separators = {
            left = "│";
            right = "│";
          };
        };
      };
    };

    bufferline = {
      enable = true;
      settings.options = {
        diagnostics = "nvim_lsp";
        always_show_bufferline = true;
        show_buffer_close_icons = false;
        show_close_icon = false;
      };
    };

    which-key.enable = true;

    neo-tree = {
      enable = true;
      settings = {
        close_if_last_window = true;
        filesystem = {
          follow_current_file.enabled = true;
          use_libuv_file_watcher = true;
          hijack_netrw_behavior = "disabled";
          filtered_items = {
            hide_dotfiles = false;
            hide_gitignored = true;
          };
        };
        window = {
          width = 35;
          mappings = {
            "<space>" = "none";
          };
        };
      };
    };

    nvim-autopairs.enable = true;
    comment.enable = true;
    todo-comments.enable = true;

    mini = {
      enable = true;
      modules = {
        # Floating-window notifications. vim.notify is rerouted in
        # extraConfigLuaPost so LSP / plugin messages render here instead of
        # the default :messages echo.
        notify = {
          lsp_progress.enable = true;
          window.winblend = 0;
        };

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
          footer = "Have a nice day!";
          items = [
            {
              name = "Find files";
              action = "Telescope find_files";
              section = "Telescope";
            }
            {
              name = "Recent files";
              action = "Telescope oldfiles";
              section = "Telescope";
            }
            {
              name = "Live grep";
              action = "Telescope live_grep";
              section = "Telescope";
            }
            {
              name = "New file";
              action = "ene | startinsert";
              section = "Builtin";
            }
            {
              name = "File explorer";
              action = "Neotree toggle";
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

    indent-blankline = {
      enable = true;
      settings.exclude.filetypes = [
        "ministarter"
        "neo-tree"
        "help"
        "lazy"
        "mason"
        "notify"
        "TelescopePrompt"
        "TelescopeResults"
        "lspinfo"
        "checkhealth"
        "man"
        "gitcommit"
        ""
      ];
    };
  };
}
