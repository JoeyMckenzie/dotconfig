{ pkgs, ... }:

{
  programs.nixvim = {
    plugins.conform-nvim = {
      enable = true;
      settings = {
        notify_on_error = true;
        default_format_opts = {
          lsp_format = "fallback";
        };

        format_on_save = {
          timeout_ms = 1000;
          lsp_format = "fallback";
        };

        formatters = {
          pint = {
            command = "vendor/bin/pint";
          };
        };

        formatters_by_ft = {
          php = {
            __unkeyed-1 = "pint";
            __unkeyed-2 = "php_cs_fixer";
            stop_after_first = true;
          };
          blade = [ "blade-formatter" ];

          javascript = [ "prettier" ];
          javascriptreact = [ "prettier" ];
          typescript = [ "prettier" ];
          typescriptreact = [ "prettier" ];
          svelte = [ "prettier" ];
          vue = [ "prettier" ];
          astro = [ "prettier" ];
          json = [ "prettier" ];
          jsonc = [ "prettier" ];
          yaml = [ "prettier" ];
          html = [ "prettier" ];
          css = [ "prettier" ];
          scss = [ "prettier" ];
          markdown = [ "prettier" ];

          lua = [ "stylua" ];
          nix = [ "nixfmt" ];
          go = [
            "goimports"
            "gofmt"
          ];
          rust = [ "rustfmt" ];
          python = [ "ruff_format" ];
          sh = [ "shfmt" ];
          bash = [ "shfmt" ];
          toml = [ "taplo" ];
        };

      };
    };

    extraPackages = with pkgs; [
      php84Packages.php-cs-fixer
      prettier
      blade-formatter
      stylua
      nixfmt
      gotools
      ruff
      shfmt
      taplo
    ];
  };
}
