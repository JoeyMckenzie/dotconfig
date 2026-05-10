{ pkgs, username, ... }:

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
      email caddy@local
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
}
