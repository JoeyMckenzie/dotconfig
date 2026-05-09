{ pkgs, ... }:

{
  programs.git.settings.user.email = "joey.mckenzie27@gmail.com";

  home.packages = [
    pkgs.claude-code
  ];

  programs.zsh.shellAliases.ccode = "claude";
}
