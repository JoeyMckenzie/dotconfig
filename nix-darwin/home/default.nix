{ ... }:

{
  imports = [
    ./packages.nix
    ./programs.nix
    ./shell.nix
    ./sops.nix
    ./neovim
    ./terminal.nix
    ./tools.nix
    ./languages.nix
  ];

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # XDG paths on Darwin — many CLI tools (lazygit, btop, ...) hardcode ~/.config regardless of OS.
  xdg.enable = true;
}
