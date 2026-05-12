{ lib, ... }:

{
  programs.btop.enable = true;
  programs.lazygit = {
    enable = true;
    settings = {
      git.pagers = [ { colorArg = "always"; } ];
    };
  };
  programs.lazydocker.enable = true;

  programs.yazi = {
    enable = true;
    enableZshIntegration = false;
  };

  xdg.configFile."btop/btop.conf".source = ./config/btop.conf;
  xdg.configFile."worktrunk/config.toml".source = ./config/worktrunk.toml;

  # lazysql global config is seeded once (not symlinked) so the UI's
  # "save connection" can write back to it. Per-project DB connections
  # belong in a hand-edited .lazysql.toml next to the project's .git.
  home.activation.seedLazysqlConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="$HOME/.config/lazysql/config.toml"
    if [ ! -e "$target" ]; then
      run mkdir -p "$(dirname "$target")"
      run install -m 0644 ${./config/lazysql.toml} "$target"
    fi
  '';
}
