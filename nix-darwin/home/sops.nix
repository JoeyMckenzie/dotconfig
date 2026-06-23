{ config, ... }:

{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    secrets."intelephense-licence" = {
      path = "${config.home.homeDirectory}/intelephense/licence.txt";
    };

    secrets."harlequin-config" = {
      path = "${config.home.homeDirectory}/.harlequin.toml";
    };

    secrets."lazysql-config" = {
      path = "${config.home.homeDirectory}/.config/lazysql/config.toml";
    };

    secrets."anthropic-api-key" = { };

    secrets."filament-blueprint-key" = { };

    templates."secrets.zsh" = {
      path = "${config.home.homeDirectory}/.config/zsh/secrets.zsh";
      content = ''
        export ANTHROPIC_API_KEY=${config.sops.placeholder."anthropic-api-key"}
        export FILAMENT_BLUEPRINT_KEY=${config.sops.placeholder."filament-blueprint-key"}
      '';
    };
  };
}
