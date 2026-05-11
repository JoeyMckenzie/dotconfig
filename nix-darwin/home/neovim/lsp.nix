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
      -- phpantom LSP (registered manually since it has no nixvim module)
      -- Build full client capabilities so phpantom's pull-model diagnostics
      -- (textDocument/diagnostic) are actually requested by the client.
      local phpantom_caps = vim.lsp.protocol.make_client_capabilities()
      local ok_blink, blink = pcall(require, 'blink.cmp')
      if ok_blink and blink.get_lsp_capabilities then
        phpantom_caps = blink.get_lsp_capabilities(phpantom_caps)
      end

      vim.lsp.config('phpantom', {
        cmd = { '${phpantom}/bin/phpantom-lsp' },
        filetypes = { 'php' },
        root_markers = { 'composer.json', '.git' },
        capabilities = phpantom_caps,
      })
      vim.lsp.enable('phpantom')

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
