{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fd
    ripgrep
    fzf
    bat
    eza
    jq
    process-compose
    gh
    broot
    aspell
    glow
    mailpit
    lazysql
    harlequin
  ];
}
