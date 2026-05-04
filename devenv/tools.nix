{ pkgs, ... }:
{
  packages = with pkgs; [
    git
    curl
    gh
    jq
    ripgrep
    fd
    fzf

    nil
    statix
    deadnix
    nixfmt-rfc-style
  ];
}
