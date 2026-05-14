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
      settings.style = "night";
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };
  };
}
