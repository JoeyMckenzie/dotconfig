{ inputs, pkgs, ... }:

let
  phpantom = pkgs.callPackage ./_pkgs/phpantom.nix {
    src = inputs.phpantom-lsp;
  };
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
        # nixd over nil_ls: cross-file navigation (gd into ./imports, into
        # nixpkgs sources, etc.) is what nil is weak at and nixd is built for.
        # Keep `nil`, `statix`, `deadnix` in home.packages — those run as CLIs
        # and are independent of which Nix LSP we use.
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
        marksman.enable = true;
        taplo.enable = true;
        # Default `glue` patterns only cover JS/TS — extend to PHP/Behat
        # locations so step definitions in Laravel projects resolve. Adjust
        # `features` / `glue` per-project via `.nvim.lua` if you stray from
        # conventional Behat layout.
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
        # Set enable = false to disable. Nixvim's module doesn't auto-discover
        # `pkgs.intelephense` (post-nodePackages migration), so package is set
        # explicitly. Setting any files.* clobbers intelephense's built-in
        # `files.exclude` defaults — we MUST repeat them or it scans
        # node_modules (~30k+ files on a Laravel project) and never finishes
        # initial indexing.
        intelephense = {
          enable = true;
          package = pkgs.intelephense;
          settings = {
            intelephense = {
              files = {
                maxSize = 5000000;
                exclude = [
                  "**/.git/**"
                  "**/.svn/**"
                  "**/.hg/**"
                  "**/CVS/**"
                  "**/.DS_Store/**"
                  "**/node_modules/**"
                  "**/bower_components/**"
                  "**/vendor/**/{Tests,tests}/**"
                  "**/.history/**"
                  "**/vendor/**/vendor/**"
                  "**/.devenv/**"
                  "**/.direnv/**"
                  "**/.phpstan/**"
                ];
              };
              environment.includePaths = [
                "vendor"
                "_ide_helper.php"
                "_ide_helper_models.php"
                ".phpstorm.meta.php"
              ];
            };
          };
        };
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
      phpantom
      laravel-lsp
    ];

    extraConfigLua = ''
      -- phpantom disabled: not yet ready for monorepo-sized codebases. To
      -- switch back, uncomment the block below and set intelephense.enable
      -- = false in the servers list above.
      --
      -- local phpantom_caps = vim.lsp.protocol.make_client_capabilities()
      -- local ok_blink, blink = pcall(require, 'blink.cmp')
      -- if ok_blink and blink.get_lsp_capabilities then
      --   phpantom_caps = blink.get_lsp_capabilities(phpantom_caps)
      -- end
      --
      -- vim.lsp.config('phpantom', {
      --   cmd = { '${phpantom}/bin/phpantom-lsp' },
      --   filetypes = { 'php' },
      --   root_markers = { 'composer.json', '.git' },
      --   capabilities = phpantom_caps,
      -- })
      -- vim.lsp.enable('phpantom')

      -- Laravel's official framework-aware LSP (routes, views/blade, config,
      -- .env, translations, middleware, etc.). Runs ALONGSIDE intelephense:
      -- intelephense handles general PHP type intelligence, laravel_lsp adds
      -- the framework-aware layer on top. Not a nixvim-module server, so it's
      -- registered manually like phpantom. `artisan`/`composer.json` lead the
      -- root markers so it roots at the Laravel app, not a monorepo `.git`
      -- above it.
      local laravel_caps = vim.lsp.protocol.make_client_capabilities()
      local ok_blink, blink = pcall(require, 'blink.cmp')
      if ok_blink and blink.get_lsp_capabilities then
        laravel_caps = blink.get_lsp_capabilities(laravel_caps)
      end

      vim.lsp.config('laravel_lsp', {
        cmd = { '${laravel-lsp}/bin/laravel-lsp' },
        filetypes = { 'php', 'blade' },
        root_markers = { 'artisan', 'composer.json', '.git' },
        capabilities = laravel_caps,
      })
      vim.lsp.enable('laravel_lsp')

      -- In a monorepo, `.git` lives above the Laravel app, so the default
      -- root resolution lands at the monorepo root and the relative
      -- `features` / `glue` globs match nothing. Pin the cucumber server's
      -- root to the nearest Behat/Composer project instead.
      vim.lsp.config('cucumber_language_server', {
        root_markers = { 'behat.yml', 'behat.yaml', 'behat.yml.dist', 'composer.json', '.git' },
      })

      -- Disable inlay hints (kept from old config for PHP LSP compat)
      vim.lsp.inlay_hint.enable(false)

      -- Diagnostic display
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
