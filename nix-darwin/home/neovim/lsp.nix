{ inputs, pkgs, ... }:

let
  phpantom = pkgs.callPackage ./_pkgs/phpantom.nix {
    src = inputs.phpantom-lsp;
  };
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
        nil_ls.enable = true;
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
        intelephense = {
          enable = true;
          # Nixvim's module doesn't know `pkgs.intelephense` lives at the top
          # level (post-nodePackages migration). Point at it explicitly.
          package = pkgs.intelephense;
          settings = {
            intelephense = {
              files = {
                maxSize = 5000000;
                # Setting any files.* clobbers intelephense's built-in
                # `files.exclude` defaults — we MUST repeat them or it scans
                # node_modules (~30k+ files on a Laravel project) and never
                # finishes initial indexing.
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

    extraPackages = [ phpantom ];

    extraConfigLua = ''
      -- phpantom disabled: indexing latency was too high. Intelephense is
      -- active via nixvim's LSP module above. To switch back, uncomment the
      -- block below and disable intelephense in the servers list.
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
