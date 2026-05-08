{ pkgs, ... }:

{
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    fd
    ripgrep
    fzf
    bat
    eza
    jq
  ];

  programs.home-manager.enable = true;
}
