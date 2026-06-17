{ ... }:

{
  programs.btop.enable = true;
  programs.lazygit = {
    enable = true;
    settings = {
      git.pagers = [
        {
          colorArg = "always";
          externalDiffCommand = "difft --color=always --display=inline";
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
}
