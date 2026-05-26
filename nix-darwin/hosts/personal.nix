{ username, ... }:

{
  home-manager.users.${username}.programs.git.settings.user.email = "joey.mckenzie27@gmail.com";

  homebrew.casks = [
    "tailscale-app"
  ];
}
