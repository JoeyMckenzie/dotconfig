{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zellij
  ];

  xdg.configFile."zellij/config.kdl".source = ./config/zellij.kdl;
  # Named layout referenced by .config/wt.toml's post-start hook in the
  # givebutter monorepo: `zellij action new-tab --layout givebutter`.
  xdg.configFile."zellij/layouts/givebutter.kdl".source = ./config/zellij-givebutter.kdl;
  home.file."Library/Application Support/com.mitchellh.ghostty/config".source = ./config/ghostty.conf;
}
