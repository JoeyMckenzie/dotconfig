{ ... }:

{
  # Disable built-in netrw so it doesn't hijack directory buffers on launch —
  # otherwise `nvim .` lands in netrw's listing before our VimEnter autocmd
  # can swap in :Dashboard. neo-tree provides the file tree we actually want.
  programs.nixvim.globals = {
    loaded_netrw = 1;
    loaded_netrwPlugin = 1;
  };

  # Fire dashboard when nvim is launched with a directory argument (e.g. `nvim .`).
  # Press `e` (or `<leader>e`) from the dashboard to open neo-tree as a side panel.
  programs.nixvim.extraConfigLua = ''
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("DashboardOnDirArg", { clear = true }),
      callback = function()
        if vim.fn.argc() ~= 1 then return end
        local arg = vim.fn.argv(0)
        if vim.fn.isdirectory(arg) ~= 1 then return end

        vim.schedule(function()
          pcall(vim.cmd.Dashboard)
        end)
      end,
    })
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

    dashboard = {
      enable = true;
      settings = {
        theme = "doom";
        hide.statusline = false;
        config = {
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
                          local max_w = 0
                          for _, line in ipairs(raw) do
                            if #line > max_w then max_w = #line end
                          end
                          local lines = { "", "" }
                          for _, line in ipairs(raw) do
                            table.insert(lines, line .. string.rep(" ", max_w - #line))
                          end
                          table.insert(lines, "")
                          table.insert(lines, os.date("%B %d, %Y"))
                          table.insert(lines, "")
                          return lines
                        end)()
          '';
          center = [
            {
              desc = "Find files               ";
              key = "f";
              key_format = "  %s";
              action = "Telescope find_files";
            }
            {
              desc = "New file                 ";
              key = "n";
              key_format = "  %s";
              action = "ene | startinsert";
            }
            {
              desc = "Recent files             ";
              key = "r";
              key_format = "  %s";
              action = "Telescope oldfiles";
            }
            {
              desc = "Live grep                ";
              key = "g";
              key_format = "  %s";
              action = "Telescope live_grep";
            }
            {
              desc = "File explorer            ";
              key = "e";
              key_format = "  %s";
              action = "Neotree toggle";
            }
            {
              desc = "Config                   ";
              key = "c";
              key_format = "  %s";
              action = "edit ~/.config/nix-darwin/home/neovim/default.nix";
            }
            {
              desc = "Quit                     ";
              key = "q";
              key_format = "  %s";
              action = "qa";
            }
          ];
          footer.__raw = ''{ "", "Have a nice day!" }'';
        };
      };
    };

    nvim-autopairs.enable = true;
    comment.enable = true;
    todo-comments.enable = true;
    indent-blankline = {
      enable = true;
      settings.exclude.filetypes = [
        "dashboard"
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
