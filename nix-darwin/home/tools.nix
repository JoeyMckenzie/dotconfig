_:

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

}
