{ username, ... }:

{
  home-manager.users.${username}.programs.git.settings.user.email = "joey@givebutter.com";

  homebrew.casks = [
    "slack"
    "zoom"
  ];
}
