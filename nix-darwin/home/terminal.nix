{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zellij
  ];

  xdg.configFile."zellij/config.kdl".source = ./zellij/config.kdl;
  xdg.configFile."ghostty/config".source = ./ghostty/config;
}
