{ inputs, username, ... }:

{
  imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

  nix-homebrew = {
    enable = true;
    user = username;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
    };
    mutableTaps = false;
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };

    casks = [
      "codex"
      "gitbutler"
      "ghostty"
      "font-symbols-only-nerd-font"
      "twingate"
      "1password"
      "notion"
      "obsidian"
      "linear"
      "raycast"
      "google-chrome"
      "vivaldi"
      "zed"
    ];

    brews = [ ];
  };
}
