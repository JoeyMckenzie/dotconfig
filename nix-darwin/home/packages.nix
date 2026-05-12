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
    figlet
    glow
    mailpit
    lazysql
    harlequin
    mysql84
    redis
    claude-code
    caddy
    devenv

    (callPackage ./_pkgs/ldcli.nix { })

    nil
    statix
    deadnix
  ];
}
