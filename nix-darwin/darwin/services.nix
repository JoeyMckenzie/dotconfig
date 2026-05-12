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

  # Shared LaunchDarkly dev server (default port 8765). Worktrees point their
  # SDKs at http://localhost:8765 instead of running their own copy. Auth and
  # synced projects live in ~/.config/ldcli/config.yml — set the access token
  # with `ldcli login` and add projects with `ldcli dev-server add-project
  # <project-key>` before relying on this.
  launchd.user.agents.ldcli = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.ldcli}/bin/ldcli"
        "dev-server"
        "start"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/Users/${username}/Library/Logs/ldcli.out.log";
      StandardErrorPath = "/Users/${username}/Library/Logs/ldcli.err.log";
    };
  };
}
