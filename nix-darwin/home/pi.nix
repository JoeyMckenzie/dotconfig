{ pkgs, ... }:

{
  home.packages = [ (pkgs.callPackage ./_pkgs/oh-my-pi.nix { }) ];
}
