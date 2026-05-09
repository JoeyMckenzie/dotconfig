{
  description = "Joey's nix-darwin systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    claude-code.url = "github:sadjow/claude-code-nix";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, claude-code, ... }:
  let
    system = "aarch64-darwin";

    mkSystem = { hostname, username, extraModules ? [] }:
      nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs username hostname; };
        modules = [
          {
            nixpkgs.overlays = [
              (final: prev: {
                claude-code =
                  claude-code.packages.${system}.claude-code;
              })
            ];
          }
          ./darwin
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.${username} = { imports = [ ./home ] ++ extraModules; };
          }
        ];
      };
  in
  {
    darwinConfigurations = {
      personal = mkSystem {
        hostname = "personal";
        username = "jmckenzie";
        extraModules = [ ./hosts/personal.nix ];
      };
      work = mkSystem {
        hostname = "work";
        username = "joey";
        extraModules = [ ./hosts/work.nix ];
      };
    };
  };
}
