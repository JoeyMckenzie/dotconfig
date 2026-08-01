{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zellij
  ];

  home.file."Library/Application Support/com.mitchellh.ghostty/config".source = ./config/ghostty.conf;
}
