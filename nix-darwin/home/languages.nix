{ pkgs, ... }:

{
  home.packages = with pkgs; [
    rustup
    go
    bun
    python313
    uv
    php84
  ];
}
