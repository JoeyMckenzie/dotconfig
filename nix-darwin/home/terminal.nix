{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zellij
  ];

  xdg.configFile."zellij/config.kdl".source = ./config/zellij.kdl;
  xdg.configFile."zellij/layouts/worktree.kdl".source = ./config/zellij-new-worktree.kdl;
  home.file."Library/Application Support/com.mitchellh.ghostty/config".source = ./config/ghostty.conf;
}
