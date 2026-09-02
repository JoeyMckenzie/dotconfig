{
  inputs,
  pkgs,
  username,
  hostname,
  ...
}:

{
  imports = [
    ./nix-settings.nix
    ./homebrew.nix
    ./system-defaults.nix
    ./services.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = hostname;
  networking.localHostName = hostname;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  programs.zsh.enable = true;

  # Touch ID for sudo — this config leans on sudo constantly (darwin-rebuild,
  # the launchctl helpers in home/shell.nix).
  security.pam.services.sudo_local.touchIdAuth = true;

  system.startup.chime = false;

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  system.primaryUser = username;
  system.stateVersion = 6;

  # Stamp the flake commit into the generation so `darwin-version` can say
  # which revision built it. Falls back to dirtyRev for uncommitted rebuilds.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
}
