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
  };
}
