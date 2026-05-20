{ pkgs, username, ... }:

let
  mysqlPkg = pkgs.mysql84;
  mysqlDataDir = "/Users/${username}/.local/share/mysql";
  mysqlSocket = "${mysqlDataDir}/mysql.sock";
  mysqlStart = pkgs.writeShellScript "mysql-start" ''
    set -eu
    DATADIR=${mysqlDataDir}
    mkdir -p "$DATADIR"
    if [ ! -d "$DATADIR/mysql" ]; then
      ${mysqlPkg}/bin/mysqld --initialize-insecure --datadir="$DATADIR"
    fi
    exec ${mysqlPkg}/bin/mysqld \
      --datadir="$DATADIR" \
      --socket=${mysqlSocket} \
      --bind-address=127.0.0.1 \
      --port=3306
  '';

  redisDataDir = "/Users/${username}/.local/share/redis";
  redisStart = pkgs.writeShellScript "redis-start" ''
    set -eu
    DATADIR=${redisDataDir}
    mkdir -p "$DATADIR"
    exec ${pkgs.redis}/bin/redis-server \
      --bind 127.0.0.1 \
      --port 6379 \
      --dir "$DATADIR" \
      --databases 64 \
      --save 60 1000 \
      --appendonly no
  '';

  postgresPkg = pkgs.postgresql_17;
  postgresDataDir = "/Users/${username}/.local/share/postgres";
  postgresStart = pkgs.writeShellScript "postgres-start" ''
    set -eu
    DATADIR=${postgresDataDir}
    mkdir -p "$DATADIR"
    if [ ! -f "$DATADIR/PG_VERSION" ]; then
      ${postgresPkg}/bin/initdb \
        -D "$DATADIR" \
        --no-locale \
        --encoding=UTF8 \
        -A trust \
        -U ${username}
    fi
    exec ${postgresPkg}/bin/postgres \
      -D "$DATADIR" \
      -h 127.0.0.1 \
      -p 5432 \
      -k "$DATADIR"
  '';

  minioDataDir = "/Users/${username}/.local/share/minio";
  minioStart = pkgs.writeShellScript "minio-start" ''
    set -eu
    DATADIR=${minioDataDir}
    mkdir -p "$DATADIR"
    export MINIO_ROOT_USER=minioadmin
    export MINIO_ROOT_PASSWORD=minioadmin
    exec ${pkgs.minio}/bin/minio server \
      --address 127.0.0.1:9000 \
      --console-address 127.0.0.1:9001 \
      "$DATADIR"
  '';
in
{
  services.dnsmasq = {
    enable = true;
    addresses = {
      test = "127.0.0.1";
    };
  };

  environment.etc."resolver/test".text = ''
    nameserver 127.0.0.1
  '';

  environment.etc."caddy/Caddyfile".text = ''
    {
      local_certs
    }

    import /Users/${username}/.config/caddy/sites/*.caddy
  '';

  launchd.daemons.caddy = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.caddy}/bin/caddy"
        "run"
        "--config"
        "/etc/caddy/Caddyfile"
        "--adapter"
        "caddyfile"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      EnvironmentVariables = {
        HOME = "/var/root";
        XDG_CONFIG_HOME = "/var/root/.config";
        XDG_DATA_HOME = "/var/root/.local/share";
      };
      StandardOutPath = "/var/log/caddy.out.log";
      StandardErrorPath = "/var/log/caddy.err.log";
    };
  };

  launchd.user.agents.mailpit = {
    serviceConfig = {
      ProgramArguments = [ "${pkgs.mailpit}/bin/mailpit" ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/Users/${username}/Library/Logs/mailpit.out.log";
      StandardErrorPath = "/Users/${username}/Library/Logs/mailpit.err.log";
    };
  };

  launchd.user.agents.mysql = {
    serviceConfig = {
      ProgramArguments = [ "${mysqlStart}" ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/Users/${username}/Library/Logs/mysql.out.log";
      StandardErrorPath = "/Users/${username}/Library/Logs/mysql.err.log";
    };
  };

  launchd.user.agents.redis = {
    serviceConfig = {
      ProgramArguments = [ "${redisStart}" ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/Users/${username}/Library/Logs/redis.out.log";
      StandardErrorPath = "/Users/${username}/Library/Logs/redis.err.log";
    };
  };

  launchd.user.agents.postgres = {
    serviceConfig = {
      ProgramArguments = [ "${postgresStart}" ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/Users/${username}/Library/Logs/postgres.out.log";
      StandardErrorPath = "/Users/${username}/Library/Logs/postgres.err.log";
    };
  };

  launchd.user.agents.minio = {
    serviceConfig = {
      ProgramArguments = [ "${minioStart}" ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/Users/${username}/Library/Logs/minio.out.log";
      StandardErrorPath = "/Users/${username}/Library/Logs/minio.err.log";
    };
  };
}
