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
    aspell
    glow
    mailpit
    lazysql
    harlequin
    mysql84
    redis
    claude-code
    caddy
    devenv

    nil
    statix
    deadnix
  ];
}
