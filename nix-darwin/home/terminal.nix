{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zellij
  ];

  xdg.configFile."zellij/config.kdl".source = ./zellij/config.kdl;
  home.file."Library/Application Support/com.mitchellh.ghostty/config".source = ./ghostty/config;
}
