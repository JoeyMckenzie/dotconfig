{ pkgs, ... }:

{
  programs.nixvim = {
    plugins.lint = {
      enable = true;
      lintersByFt = {
        php = [ "phpstan" ];
        javascript = [ "eslint" ];
        javascriptreact = [ "eslint" ];
        typescript = [ "eslint" ];
        typescriptreact = [ "eslint" ];
        svelte = [ "eslint" ];
        nix = [
          "statix"
          "deadnix"
        ];
        lua = [ "luacheck" ];
        python = [ "ruff" ];
      };

      autoCmd = {
        event = [
          "BufWritePost"
          "BufReadPost"
          "InsertLeave"
        ];
        callback.__raw = ''
          function()
            require('lint').try_lint()
          end
        '';
      };
    };

    extraPackages = with pkgs; [
      phpstan
      eslint_d
      statix
      deadnix
      luaPackages.luacheck
      ruff
    ];
  };
}
