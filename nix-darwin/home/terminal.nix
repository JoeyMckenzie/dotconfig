{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zellij
  ];

  xdg.configFile."zellij/config.kdl".source = ./config/zellij.kdl;
  home.file."Library/Application Support/com.mitchellh.ghostty/config".source = ./config/ghostty.conf;
}
