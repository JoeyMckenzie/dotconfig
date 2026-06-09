{ ... }:

{
  imports = [
    ./options.nix
    ./keymaps.nix
    ./ui.nix
    ./completion.nix
    ./lsp.nix
    ./treesitter.nix
    ./formatting.nix
    ./linting.nix
    ./git.nix
    ./octo.nix
    ./harpoon.nix
    ./neotest.nix
    ./dap.nix
    ./aerial.nix
    ./laravel.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    colorschemes.tokyonight = {
      enable = true;
      settings = {
        style = "night";
        transparent = true;
        styles.sidebars = "transparent";
        styles.floats = "transparent";
      };
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };
  };
}
