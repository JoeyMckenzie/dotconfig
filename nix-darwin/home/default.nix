{ ... }:

{
  imports = [
    ./packages.nix
    ./programs.nix
    ./shell.nix
    ./neovim
    ./terminal.nix
    ./tools.nix
    ./languages.nix
  ];

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
