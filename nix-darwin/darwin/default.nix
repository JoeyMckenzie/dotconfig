{ pkgs, username, hostname, ... }:

{
  imports = [
    ./nix-settings.nix
    ./homebrew.nix
    ./system-defaults.nix
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

  system.primaryUser = username;
  system.stateVersion = 6;
  system.configurationRevision = null;
}
