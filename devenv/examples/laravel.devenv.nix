{ pkgs, lib, ... }:

# Project-level devenv.nix template. Copy to a new Laravel project's repo
# root and update the `slug` binding below. Pairs with the shared infra at
# ~/.config/devenv (Postgres, Redis, Caddy on *.test:8443, Mailpit, dnsmasq).
#
# First-time setup for a new project:
#   1. cd ~/.config/devenv && register-project <slug>
#        creates Postgres role <slug>/<slug> and template DB <slug>_main
#   2. (per worktree, optional) write-site <slug> <short> <app_port> <vite_port>
#        then reload-caddy   — exposes https://<slug>-<short>.test:8443
#
# Sibling files this template recognizes (all optional):
#   ./.devenv-index    integer offset for port multiplexing across worktrees
#   ./php.ini.base     base INI fragment merged into PHP config
#   ./php.local.ini    untracked per-developer overrides

let
  # ── change this when copying for a new project ──
  slug = "myapp";

  rawName = builtins.baseNameOf (toString ./.);
  shortName = lib.removePrefix "${slug}-" rawName;

  indexFile = ./.devenv-index;
  index =
    if builtins.pathExists indexFile then
      lib.toInt (lib.removeSuffix "\n" (builtins.readFile indexFile))
    else
      0;

  appPort = 8000 + index;
  vitePort = 5173 + index;
  xdebugPort = 9003 + index;
  dbName = "${slug}_" + lib.replaceStrings [ "-" "." ] [ "_" "_" ] shortName;
  hostname = "${slug}-${shortName}.test";

  toolsPath = /. + "${builtins.getEnv "HOME"}/.config/devenv/tools.nix";
in
{
  imports = [ toolsPath ];

  dotenv.disableHint = true;

  languages.php = {
    enable = true;
    version = "8.4";
    extensions = [
      "redis"
      "pdo_pgsql"
      "pgsql"
      "intl"
      "bcmath"
      "gd"
      "zip"
      "xdebug"
    ];
    ini = ''
      ${lib.optionalString (builtins.pathExists ./php.ini.base) (builtins.readFile ./php.ini.base)}
      xdebug.client_port = ${toString xdebugPort}
      ${lib.optionalString (builtins.pathExists ./php.local.ini) (builtins.readFile ./php.local.ini)}
    '';
  };

  languages.javascript = {
    enable = true;
    package = pkgs.nodejs_22;
    npm.enable = true;
  };

  packages = with pkgs; [
    postgresql_16
    redis
  ];

  processes.app.exec = "php artisan serve --host=127.0.0.1 --port=${toString appPort}";
  processes.queue.exec = "php artisan queue:listen --tries=1";
  processes.horizon.exec = "php artisan horizon";
  processes.vite.exec = "npm run dev -- --port ${toString vitePort} --strictPort";

  processes.migrate = {
    exec = "php artisan migrate --force";
    process-compose.availability.restart = "no";
  };
  processes.app.process-compose.depends_on.migrate.condition = "process_completed_successfully";
  processes.horizon.process-compose.depends_on.migrate.condition = "process_completed_successfully";
  processes.queue.process-compose.depends_on.migrate.condition = "process_completed_successfully";

  env = {
    APP_URL = "https://${hostname}";
    APP_PORT = toString appPort;

    XDEBUG_PORT = toString xdebugPort;

    DB_CONNECTION = "pgsql";
    DB_HOST = "127.0.0.1";
    DB_PORT = "5432";
    DB_DATABASE = dbName;
    DB_USERNAME = slug;
    DB_PASSWORD = slug;

    REDIS_CLIENT = "predis";
    REDIS_HOST = "127.0.0.1";
    REDIS_PORT = "6379";
    REDIS_DB = toString index;

    MAIL_MAILER = "smtp";
    MAIL_HOST = "127.0.0.1";
    MAIL_PORT = "1025";
  };

  enterShell = ''
    echo "── ${shortName} (index=${toString index}) ──"
    echo "  url   https://${hostname}"
    echo "  app   127.0.0.1:${toString appPort}"
    echo "  vite  127.0.0.1:${toString vitePort}"
    echo "  db    ${dbName}"
    echo "  redis db=${toString index}"

    if PGPASSWORD=${slug} psql -h 127.0.0.1 -U ${slug} -d postgres -c '\q' &>/dev/null; then
      if ! PGPASSWORD=${slug} psql -h 127.0.0.1 -U ${slug} -d ${dbName} -c '\q' &>/dev/null; then
        echo "Cloning ${slug}_main → ${dbName}…"
        PGPASSWORD=${slug} psql -h 127.0.0.1 -U ${slug} -d postgres -c \
          "SELECT pg_terminate_backend(pid) FROM pg_stat_activity \
           WHERE datname='${slug}_main' AND pid <> pg_backend_pid();" >/dev/null
        PGPASSWORD=${slug} createdb -h 127.0.0.1 -U ${slug} -T ${slug}_main ${dbName}
      fi
    else
      echo "⚠ shared Postgres not reachable — run \`devenv up\` from ~/.config/devenv first"
    fi

    [ ! -d vendor ]       && composer install
    [ ! -d node_modules ] && npm install
    [ ! -f .env ]         && cp .env.example .env && php artisan key:generate
  '';
}
