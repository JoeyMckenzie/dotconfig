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
    claude-code
    caddy

    # Nix tooling for nvim (LSP + linters)
    nil
    statix
    deadnix
  ];
}
