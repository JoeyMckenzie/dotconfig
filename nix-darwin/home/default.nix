{ ... }:

{
  imports = [
    ./packages.nix
    ./programs.nix
    ./shell.nix
    ./editors.nix
    ./terminal.nix
    ./tools.nix
  ];

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
