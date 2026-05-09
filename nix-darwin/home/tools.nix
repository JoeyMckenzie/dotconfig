{ ... }:

{
  programs.btop.enable = true;
  programs.htop.enable = true;
  programs.lazygit.enable = true;
  programs.lazydocker.enable = true;

  programs.yazi = {
    enable = true;
    enableZshIntegration = false;
  };
}
