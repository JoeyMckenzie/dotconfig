{ pkgs, lib, config, ... }:
{
  imports = [ ./tools.nix ];

  claude.code.enable = true;

  packages = with pkgs; [ postgresql_16 redis dnsmasq caddy ];

  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;
    listen_addresses = "127.0.0.1";
  };

  services.mysql = {
    enable = true;
    package = pkgs.mysql84;
    settings.mysqld = {
      port = 3306;
      bind-address = "127.0.0.1";
    };
  };

  services.redis = {
    enable = true;
    bind = "127.0.0.1";
    port = 6379;
    extraConfig = ''
      databases 64
    '';
  };

  services.mailpit.enable = true;

  processes.dnsmasq.exec = ''
    exec ${pkgs.dnsmasq}/bin/dnsmasq \
      --keep-in-foreground \
      --port=8053 \
      --address=/test/127.0.0.1 \
      --no-resolv \
      --log-facility=-
  '';

  processes.caddy.exec = ''
    exec ${pkgs.caddy}/bin/caddy run \
      --config ${toString ./Caddyfile} \
      --adapter caddyfile
  '';

  process.managers.process-compose.tui.enable = false;

  enterShell = ''
    export PATH="$HOME/.config/devenv/bin:$PATH"
    echo "── shared infra (~/.config/devenv) ──"
    echo "  https://*.test:8443       (Caddy + internal CA)"
    echo "  postgres  127.0.0.1:5432  (per-project roles via register-project)"
    echo "  mysql     127.0.0.1:3306  (mysql 8.4)"
    echo "  redis     127.0.0.1:6379  (64 DBs)"
    echo "  mailpit   smtp:1025       ui:http://127.0.0.1:8025"
    echo "  helpers   register-project | write-site | reload-caddy"
  '';
}
