_:

{
  programs.btop.enable = true;
  programs.lazygit = {
    enable = true;
    settings = {
      git.diffRenderers = [
        {
          colorArg = "always";
          type = "extDiff";
          command = "difft --color=always --display=inline";
        }
      ];
    };
  };

  programs.lazydocker.enable = true;

  programs.yazi = {
    enable = true;
    enableZshIntegration = false;
  };

  xdg.configFile."btop/btop.conf".source = ./config/btop.conf;
  xdg.configFile."btop/themes/tokyonight_night.theme".source = ./config/btop-tokyonight-night.theme;
  xdg.configFile."worktrunk/config.toml".source = ./config/worktrunk.toml;
  xdg.configFile."opencode/opencode.json".source = ./config/opencode.json;
  xdg.configFile."crush/crush.json".source = ./config/crush.json;
  xdg.configFile."herdr/config.toml".source = ./config/herdr.toml;
  xdg.configFile."graphite/aliases".source = ./config/graphite-aliases;
  xdg.configFile."superfile/config.toml".source = ./config/superfile-config.toml;
  xdg.configFile."superfile/hotkeys.toml".source = ./config/superfile-hotkeys.toml;
}
