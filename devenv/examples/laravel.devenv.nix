{ pkgs, lib, ... }:

# Project-level devenv.nix template. Copy to a new Laravel project's repo
# root and update the `slug` and `dbDriver` bindings below. Pairs with the
# shared infra at ~/.config/devenv (Postgres, MySQL, Redis, Caddy on
# *.test:8443, Mailpit, dnsmasq).
#
# First-time setup for a new project:
#   1. cd ~/.config/devenv && register-project <slug>              # postgres (default)
#      cd ~/.config/devenv && register-project <slug> --db mysql   # mysql
#      cd ~/.config/devenv && register-project <slug> --db sqlite  # sqlite (no-op)
#      cd ~/.config/devenv && register-project <slug> --db both    # both servers
#   2. (per worktree, optional) write-site <hostname> <app_port> <vite_port>
#        then reload-caddy   — exposes https://<slug>.test:8443 (main, apex)
#        or https://<short>.<slug>.test:8443 (worktree, subdomain)
#
# After copying, also align the project's .env.example with the slug:
#   APP_URL=https://<slug>.test:8443
#   SESSION_DOMAIN=.<slug>.test
# Laravel's .env wins over devenv shell env, so these have to be in the dotfile
# for the framework to honor them at runtime.
#
# Sibling files this template recognizes (all optional):
#   ./.devenv-index    integer offset for port multiplexing across worktrees
#   ./php.ini.base     base INI fragment merged into PHP config
#   ./php.local.ini    untracked per-developer overrides

let
  # ── change these when copying for a new project ──
  slug = "myapp";
  dbDriver = "pgsql"; # "pgsql", "mysql", or "sqlite"

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
  hostname =
    if shortName == "main"
    then "${slug}.test"
    else "${shortName}.${slug}.test";

  toolsPath = /. + "${builtins.getEnv "HOME"}/.config/devenv/tools.nix";

  sqlitePath = "${toString ./.}/database/database.sqlite";

  phpDbExtensions =
    if dbDriver == "pgsql" then [ "pdo_pgsql" "pgsql" ]
    else if dbDriver == "mysql" then [ "pdo_mysql" "mysqli" ]
    else [ "pdo_sqlite" ];

  dbEnv =
    if dbDriver == "pgsql" then {
      DB_CONNECTION = "pgsql";
      DB_HOST = "127.0.0.1";
      DB_PORT = "5432";
      DB_DATABASE = dbName;
      DB_USERNAME = slug;
      DB_PASSWORD = slug;
    }
    else if dbDriver == "mysql" then {
      DB_CONNECTION = "mysql";
      DB_HOST = "127.0.0.1";
      DB_PORT = "3306";
      DB_DATABASE = dbName;
      DB_USERNAME = slug;
      DB_PASSWORD = slug;
    }
    else {
      DB_CONNECTION = "sqlite";
      DB_DATABASE = sqlitePath;
    };

  dbBootstrap =
    if dbDriver == "pgsql" then ''
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
    ''
    else if dbDriver == "mysql" then ''
      if MYSQL_PWD=${slug} mysql -h 127.0.0.1 -u ${slug} -e 'select 1' &>/dev/null; then
        MYSQL_PWD=${slug} mysql -h 127.0.0.1 -u ${slug} \
          -e 'CREATE DATABASE IF NOT EXISTS `${dbName}`'
      else
        echo "⚠ shared MySQL not reachable — run \`devenv up\` from ~/.config/devenv first"
      fi
    ''
    else ''
      mkdir -p database
      [ -f ${sqlitePath} ] || touch ${sqlitePath}
    '';
in
{
  imports = [ toolsPath ];

  dotenv.disableHint = true;

  languages.php = {
    enable = true;
    version = "8.4";
    extensions = [
      "redis"
      "intl"
      "bcmath"
      "gd"
      "zip"
      "xdebug"
    ] ++ phpDbExtensions;
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
  processes.logs.exec = "php artisan pail --timeout=0";
  processes.horizon.exec = "php artisan horizon";
  processes.vite.exec = "npm run dev -- --port ${toString vitePort} --strictPort";

  processes.migrate = {
    exec = "php artisan migrate --force";
    process-compose.availability.restart = "no";
  };
  processes.app.process-compose.depends_on.migrate.condition = "process_completed_successfully";
  processes.horizon.process-compose.depends_on.migrate.condition = "process_completed_successfully";
  processes.queue.process-compose.depends_on.migrate.condition = "process_completed_successfully";

  env = dbEnv // {
    APP_URL = "https://${hostname}:8443";
    APP_PORT = toString appPort;

    # Cookies span all worktree subdomains (main apex + every <short>.<slug>.test).
    # Note: Laravel's `.env` wins over shell env in practice, so this also needs
    # to be set in `.env` / `.env.example` for the framework to honor it.
    SESSION_DOMAIN = ".${slug}.test";

    XDEBUG_PORT = toString xdebugPort;

    REDIS_CLIENT = "predis";
    REDIS_HOST = "127.0.0.1";
    REDIS_PORT = "6379";
    REDIS_DB = toString index;

    MAIL_MAILER = "smtp";
    MAIL_HOST = "127.0.0.1";
    MAIL_PORT = "1025";
  };

  enterShell = ''
    echo "── ${shortName} (index=${toString index}, db=${dbDriver}) ──"
    echo "  url   https://${hostname}:8443"
    echo "  app   127.0.0.1:${toString appPort}"
    echo "  vite  127.0.0.1:${toString vitePort}"
    echo "  db    ${dbName}"
    echo "  redis db=${toString index}"

    ${dbBootstrap}

    [ ! -d vendor ]       && composer install
    [ ! -d node_modules ] && npm install
    [ ! -f .env ]         && cp .env.example .env && php artisan key:generate
  '';
}
