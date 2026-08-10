{
  username,
  pkgs,
  ...
}:

{
  home-manager.users.${username} = {
    programs.git.settings.user.email = "joey.mckenzie27@gmail.com";

    home.packages = with pkgs; [
      cmake
      boost
      boost.dev
    ];
  };

  homebrew.casks = [
    "tailscale-app"
    "lm-studio"
  ];
}
