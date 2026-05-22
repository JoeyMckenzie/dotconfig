{ config, ... }:

{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    secrets."intelephense-licence" = {
      path = "${config.home.homeDirectory}/intelephense/licence.txt";
    };
  };
}
