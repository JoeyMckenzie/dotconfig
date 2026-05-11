{ ... }:

{
  # Fire dashboard when nvim is launched with a directory argument (e.g. `nvim .`).
  # Neo-tree hijacks the directory buffer on the left; we schedule :Dashboard
  # into the right-hand window so both panes render together.
  programs.nixvim.extraConfigLua = ''
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("DashboardOnDirArg", { clear = true }),
      callback = function()
        if vim.fn.argc() ~= 1 then return end
        local arg = vim.fn.argv(0)
        if vim.fn.isdirectory(arg) ~= 1 then return end

        vim.schedule(function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
            if ft ~= "neo-tree" then
              vim.api.nvim_set_current_win(win)
              pcall(vim.cmd.Dashboard)
              return
            end
          end
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
              return {
                "",
                "",
                "",
                "",
                os.date("%A"):upper(),
                os.date("%B %d, %Y"),
                "",
                "",
              }
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
