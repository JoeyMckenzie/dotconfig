{ pkgs, ... }:

let
  laravel-lsp = pkgs.callPackage ./_pkgs/laravel-lsp.nix { };
in
{
  programs.nixvim = {
    plugins.lsp = {
      enable = true;

      servers = {
        ts_ls.enable = true;
        gopls.enable = true;

        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
        };

        nixd.enable = true;
        lua_ls.enable = true;
        tailwindcss.enable = true;
        jsonls.enable = true;
        yamlls.enable = true;
        bashls.enable = true;
        html.enable = true;
        cssls.enable = true;
        svelte.enable = true;
        astro.enable = true;
        vue_ls.enable = true;
        marksman.enable = true;
        taplo.enable = true;

        ty.enable = true;
        basedpyright.enable = true;
        ruff = {
          enable = true;
          # basedpyright already provides hover; avoid duplicate/conflicting popups.
          onAttach.function = ''
            client.server_capabilities.hoverProvider = false
          '';
        };

        harper_ls = {
          enable = true;
          package = pkgs.harper;
          settings = {
            "harper-ls" = {
              userDictPath = "~/.config/harper/dict.txt";
              linters = {
                SentenceCapitalization = false;
                SpellCheck = true;
              };
              codeActions.ForceStable = true;
              markdown.IgnoreLinkTitle = false;
            };
          };
        };

        cucumber_language_server = {
          enable = true;
          package = pkgs.callPackage ./_pkgs/cucumber-language-server.nix { };
          settings = {
            cucumber = {
              features = [
                "tests/Behat/Features/**/*.feature"
              ];
              glue = [
                "tests/Behat/Contexts/**/*.php"
                "tests/Behat/Support/**/*.php"
              ];
            };
          };
        };

        phpantom_lsp.enable = true;

        # intelephense = {
        #   enable = true;
        #   package = pkgs.intelephense;
        #   settings = {
        #     intelephense = {
        #       files = {
        #         maxSize = 5000000;
        #         exclude = [
        #           "**/.git/**"
        #           "**/.svn/**"
        #           "**/.hg/**"
        #           "**/CVS/**"
        #           "**/.DS_Store/**"
        #           "**/node_modules/**"
        #           "**/bower_components/**"
        #           "**/vendor/**/{Tests,tests}/**"
        #           "**/.history/**"
        #           "**/vendor/**/vendor/**"
        #           "**/.devenv/**"
        #           "**/.direnv/**"
        #           "**/.phpstan/**"
        #         ];
        #       };
        #       environment.includePaths = [
        #         "vendor"
        #         "_ide_helper.php"
        #         "_ide_helper_models.php"
        #         ".phpstorm.meta.php"
        #       ];
        #     };
        #   };
        # };
      };

      keymaps = {
        lspBuf = {
          "gd" = "definition";
          "gD" = "declaration";
          "gi" = "implementation";
          "gr" = "references";
          "K" = "hover";
          "<leader>ca" = "code_action";
          "<leader>rn" = "rename";
          "<leader>cs" = "signature_help";
        };
      };
    };

    extraPackages = [
      laravel-lsp
    ];

    extraConfigLua = ''
      local laravel_caps = vim.lsp.protocol.make_client_capabilities()
      local ok_blink, blink = pcall(require, 'blink.cmp')
      if ok_blink and blink.get_lsp_capabilities then
        laravel_caps = blink.get_lsp_capabilities(laravel_caps)
      end

      vim.lsp.config('laravel_lsp', {
        cmd = { '${laravel-lsp}/bin/laravel-lsp' },
        filetypes = { 'php', 'blade' },
        -- laravel-lsp rejects `initialize` outright ("root URI must be a
        -- Laravel project") for any root that isn't a Laravel app, so root
        -- detection has to be exact. `composer.json`/`.git` markers matched
        -- every PHP repo — and in a monorepo they'd resolve to the repo root
        -- rather than the app dir. `artisan` is the marker that actually
        -- identifies a Laravel root.
        --
        -- Using the root_dir callback rather than root_markers so that not
        -- finding `artisan` leaves the server unstarted: with root_markers,
        -- a miss still starts it with a nil root and trips the same error.
        root_dir = function(bufnr, on_dir)
          local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
          if dir == nil or dir == "" then
            return
          end
          local artisan = vim.fs.find('artisan', { path = dir, upward = true, type = 'file' })[1]
          if artisan then
            on_dir(vim.fs.dirname(artisan))
          end
        end,
        capabilities = laravel_caps,
      })

      vim.lsp.enable('laravel_lsp')

      vim.lsp.config('cucumber_language_server', {
        root_markers = { 'behat.yml', 'behat.yaml', 'behat.yml.dist', 'composer.json', '.git' },
      })

      vim.lsp.inlay_hint.enable(false)

      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = 'rounded', source = true },
      })
    '';
  };
}
