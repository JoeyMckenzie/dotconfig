{ config, pkgs, ... }:

{
  home.packages = [ (pkgs.callPackage ./_pkgs/oh-my-pi.nix { }) ];

  programs.pi.coding-agent = {
    enable = true;
    environment.PI_CODING_AGENT_DIR.value = "${config.home.homeDirectory}/.config/pi";
  };
}
