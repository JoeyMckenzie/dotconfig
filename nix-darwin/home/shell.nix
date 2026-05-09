{ config, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    dotDir = "${config.xdg.configHome}/zsh";
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      share = true;
    };

    sessionVariables = {
      XDG_CONFIG_HOME = "$HOME/.config";
      STARSHIP_CONFIG = "$HOME/.config/starship/starship.toml";
      BUN_INSTALL = "$HOME/.bun";
    };

    shellAliases = {
      pa = "php artisan";
      hpa = "herd php artisan";
      sail = "sh $([ -f sail ] && echo sail || echo vendor/bin/sail)";
      sa = "./vendor/bin/sail";
      sf = "php bin/console";

      wip = "git commit -am 'chore: wip' && git push";
      yeet = "git commit -am 'chore: wip' --no-verify && git push --no-verify";

      lg = "lazygit";
      lzd = "lazydocker";
      cvim = "clear && nvim .";
      nv = "clear && nvim .";

      ls = "eza --icons --git --git-ignore";
      cat = "bat";

      devenv-orphans = ''ps -axo pid,ppid,command | rg -v "claude|rg" | awk "\$2==1 && /vite|php artisan|redis-server|caddy|mailpit/ {print}"'';
      devenv-kill = "$HOME/.config/devenv/bin/devenv-kill-orphans";
    };

    initContent = ''
      # User dev-tool bin dirs — APPENDED so nix paths win
      path+=(
        "$HOME/bin"
        "$HOME/.codeium/windsurf/bin"
        "$HOME/.opencode/bin"
        "$HOME/go/bin"
        "$HOME/.composer/vendor/bin"
        "$HOME/.churn/bin"
      )

      # Multi-arg commit functions (zsh aliases can't take positional args cleanly)
      gc()   { git commit -am "$*"; }
      gcy()  { git commit -am "$*" --no-verify; }
      gcp()  { git commit -am "$*" && git push; }
      gcpy() { git commit -am "$*" --no-verify && git push --no-verify; }

      # Yazi with cwd-jump
      y() {
        local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
        command yazi "$@" --cwd-file="$tmp"
        IFS= read -r -d "" cwd < "$tmp"
        [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
        rm -f -- "$tmp"
      }

      # Bun completions
      [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

      # Worktrunk completions
      command -v wt >/dev/null 2>&1 && eval "$(command wt config shell init zsh)"
    '';
  };

}
