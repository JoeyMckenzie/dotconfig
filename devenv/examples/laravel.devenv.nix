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
# Env-var ownership:
#   - Per-worktree dynamic values (APP_URL, APP_PORT, DB_DATABASE, REDIS_DB,
#     XDEBUG_PORT) are computed below and exported via `env = { }`.
#   - Project-static values (DB_HOST/USERNAME/PASSWORD, REDIS_HOST/PORT/CLIENT,
#     MAIL_*, SESSION_DOMAIN, APP_NAME, APP_KEY, etc.) live in .env / .env.example.
#   - Shell env (devenv) wins over .env (Laravel reads .env in immutable mode),
#     so anything in both places will be served from devenv. Keep them disjoint.
# Sibling template: laravel.env.example in this same dir — copy it to your
# project as .env.example and find/replace `<slug>`.
#
# Sibling files this template recognizes (all optional):
#   ./.devenv-index    integer offset for port multiplexing across worktrees
#   ./php.ini.base     base INI fragment merged into PHP config
#   ./php.local.ini    untracked per-developer overrides

let
  # ── change these when copying for a new project ──
  slug = "myapp";
  dbDriver = "pgsql"; # "pgsql", "mysql", or "sqlite"

  worktreeName = builtins.baseNameOf (toString ./.);

  indexFile = ./.devenv-index;
  index =
    if builtins.pathExists indexFile then
      lib.toInt (lib.removeSuffix "\n" (builtins.readFile indexFile))
    else
      0;

  appPort = 8000 + index;
  vitePort = 5173 + index;
  xdebugPort = 9003 + index;
  dbName = "${slug}_" + lib.replaceStrings [ "-" "." ] [ "_" "_" ] worktreeName;
  hostname =
    if worktreeName == "main"
    then "${slug}.test"
    else "${worktreeName}.${slug}.test";

  toolsPath = /. + "${builtins.getEnv "HOME"}/.config/devenv/tools.nix";

  sqlitePath = "${toString ./.}/database/database.sqlite";

  phpDbExtensions =
    if dbDriver == "pgsql" then [ "pdo_pgsql" "pgsql" ]
    else if dbDriver == "mysql" then [ "pdo_mysql" "mysqli" ]
    else [ "pdo_sqlite" ];

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

  # Per-worktree dynamic env. Static config (DB_HOST, DB_USERNAME, REDIS_*,
  # MAIL_*, SESSION_DOMAIN, etc.) lives in .env / .env.example.
  env = {
    APP_URL = "https://${hostname}:8443";
    APP_PORT = toString appPort;
    DB_DATABASE = if dbDriver == "sqlite" then sqlitePath else dbName;
    REDIS_DB = toString index;
    XDEBUG_PORT = toString xdebugPort;
  };

  enterShell = ''
    echo "── ${worktreeName} (index=${toString index}, db=${dbDriver}) ──"
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
