{ pkgs, lib, config, ... }:
{
  imports = [ ./tools.nix ];

  packages = with pkgs; [ postgresql_16 redis dnsmasq caddy ];

  languages.php = {
    enable = true;
    version = "8.4";
    extensions = [ "redis" "intl" "imagick" ];
    ini = ''
      memory_limit = 512M
      upload_max_filesize = 100M
      post_max_size = 100M
    '';
  };

  languages.javascript = {
    enable = true;
    package = pkgs.nodejs_22;
    npm.enable = true;
    pnpm.enable = true;
    bun.enable = true;
  };

  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;
    listen_addresses = "127.0.0.1";
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
    echo "  php       8.4              (redis, intl, imagick)"
    echo "  node      22               (npm, pnpm, bun)"
    echo "  postgres  127.0.0.1:5432  (per-project roles via register-project)"
    echo "  redis     127.0.0.1:6379  (64 DBs)"
    echo "  mailpit   smtp:1025       ui:http://127.0.0.1:8025"
    echo "  helpers   register-project | write-site | reload-caddy"
  '';
}
