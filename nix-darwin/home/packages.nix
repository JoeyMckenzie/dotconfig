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

    # Nix tooling for nvim (LSP + linters)
    nil
    statix
    deadnix
  ];
}
