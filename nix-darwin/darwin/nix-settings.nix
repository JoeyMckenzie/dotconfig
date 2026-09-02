{ username, ... }:

{
  nix = {
    # Drop nix-darwin's default `/nix/var/nix/profiles/per-user/root/channels`
    # entry — this is a flakes-only setup, root has no channels, and every
    # evaluation warns that the path doesn't exist.
    nixPath = [ "nixpkgs=flake:nixpkgs" ];

    # /nix was sitting at 85% with 50 system generations and no collection.
    gc = {
      automatic = true;
      interval = [
        {
          Weekday = 7;
          Hour = 3;
          Minute = 15;
        }
      ];
      options = "--delete-older-than 30d";
    };

    # nix-darwin asserts against nix.settings.auto-optimise-store (store
    # corruption); the scheduled optimiser is the supported path.
    optimise.automatic = true;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      extra-substituters = [
        "https://cache.lix.systems"
        "https://nix-community.cachix.org"
        "https://numtide.cachix.org"
        "https://pi.cachix.org"
      ];
      extra-trusted-public-keys = [
        "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "pi.cachix.org-1:lGeoGJaZ5ZDabuRzkcD5EBTNnDM4HJ1vqeOxlWk1Flk="
      ];
      trusted-users = [
        "@admin"
        username
      ];
    };
  };
}
