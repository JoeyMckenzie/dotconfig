{
  description = "Joey's nix-darwin systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    claude-code.url = "github:sadjow/claude-code-nix";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # phpantom_lsp's deps need rustc 1.95+, newer than what nixpkgs ships.
    # We build it ourselves with rust-overlay providing the latest stable rustc.
    phpantom-lsp = {
      url = "github:AJenbo/phpantom_lsp";
      flake = false;
    };

    # laravel.nvim isn't packaged in nixpkgs.vimPlugins; we build it ourselves
    # via vimUtils.buildVimPlugin in home/neovim/_pkgs/laravel-nvim.nix.
    laravel-nvim = {
      url = "github:adalessa/laravel.nvim";
      flake = false;
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Don't follow nixpkgs — worktrunk pins its own (with matching rust-overlay
    # and crane setup). Following ours risks a rustc mismatch like phpantom hit.
    worktrunk.url = "github:max-sixty/worktrunk";

    herdr.url = "github:ogulcancelik/herdr";

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

  outputs =
    inputs@{
      nixpkgs,
      nix-darwin,
      home-manager,
      claude-code,
      nixvim,
      rust-overlay,
      git-hooks,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      preCommitCheck = git-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixfmt-rfc-style.enable = true;
          statix.enable = true;
          deadnix.enable = true;
        };
      };

      mkSystem =
        {
          hostname,
          username,
          hostFile,
        }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs username hostname; };
          modules = [
            inputs.lix-module.darwinModules.lixFromNixpkgs
            {
              # MinIO FOSS edition is in maintenance-only mode upstream and
              # nixpkgs gates it on knownVulnerabilities. The listed CVEs all
              # require internet-facing auth/replication/OIDC/LDAP — none of
              # which apply to our 127.0.0.1-bound dev S3 instance.
              nixpkgs.config.permittedInsecurePackages = [
                "minio-2025-10-15T17-29-55Z"
              ];

              nixpkgs.overlays = [
                rust-overlay.overlays.default
                inputs.herdr.overlays.default
                (final: prev: {
                  claude-code = claude-code.packages.${system}.claude-code;
                  agent-browser = final.callPackage ./home/_pkgs/agent-browser.nix { };
                  # nixpkgs harlequin ships postgres + bigquery adapters but not
                  # mysql, and harlequin-mysql isn't in nixpkgs at all. Build the
                  # PyPI package locally and splice it into harlequin's deps so
                  # `harlequin -a mysql` works after every darwin-rebuild.
                  harlequin = prev.harlequin.overridePythonAttrs (old: {
                    dependencies = old.dependencies ++ [
                      (final.python3Packages.callPackage ./home/_pkgs/harlequin-mysql.nix { })
                    ];
                  });
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
              home-manager.users.${username}.imports = [
                nixvim.homeModules.nixvim
                inputs.worktrunk.homeModules.default
                inputs.sops-nix.homeManagerModules.sops
                ./home
              ];
            }
            hostFile
          ];
        };
    in
    {
      formatter.${system} = pkgs.nixfmt;

      checks.${system}.pre-commit-check = preCommitCheck;

      devShells.${system}.default = pkgs.mkShell {
        inherit (preCommitCheck) shellHook;
        buildInputs = preCommitCheck.enabledPackages;
      };

      darwinConfigurations = {
        personal = mkSystem {
          hostname = "personal";
          username = "jmckenzie";
          hostFile = ./hosts/personal.nix;
        };
        work = mkSystem {
          hostname = "work";
          username = "joeymckenzie";
          hostFile = ./hosts/work.nix;
        };
      };
    };
}
