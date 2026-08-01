{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.gh
    pkgs.gh-dash
  ];

  programs = {
    git = {
      enable = true;
      ignores = [ ".claude/settings.local.json" ];
      settings = {
        user.name = "Joey McKenzie";
        http.postBuffer = 1048576000;
        merge.conflictStyle = "zdiff3";
        init.defaultBranch = "main";
        credential = {
          "https://github.com".helper = [
            ""
            "${pkgs.gh}/bin/gh auth git-credential"
          ];
          "https://gist.github.com".helper = [
            ""
            "${pkgs.gh}/bin/gh auth git-credential"
          ];
        };
      };
    };

    difftastic = {
      enable = true;
      options = {
        background = "dark";
        display = "inline";
        color = "always";
      };
      git = {
        enable = true;
        mode = "both";
      };
    };

    broot = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        show_selection_mark = true;
        verbs = [
          {
            invocation = "edit";
            shortcut = "e";
            key = "ctrl-e";
            apply_to = "text_file";
            execution = "$EDITOR {file}";
            leave_broot = false;
          }
          {
            invocation = "create {subpath}";
            execution = "$EDITOR {directory}/{subpath}";
            leave_broot = false;
          }
          {
            invocation = "git_diff";
            shortcut = "gd";
            leave_broot = false;
            execution = "git difftool -y {file}";
          }
          {
            invocation = "backup {version}";
            key = "ctrl-b";
            leave_broot = false;
            auto_exec = false;
            execution = "cp -r {file} {parent}/{file-stem}-{version}{file-dot-extension}";
          }
          {
            invocation = "terminal";
            key = "ctrl-t";
            execution = "$SHELL";
            set_working_dir = true;
            leave_broot = false;
          }
        ];
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
      stdlib = ''
        eval "$(devenv direnvrc)"
      '';
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      # Yield Ctrl-R to atuin, which owns shell history.
      historyWidget.zsh.command = "";
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
    };

    tealdeer = {
      enable = true;
      settings.updates.auto_update = true;
    };

    atuin = {
      enable = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    pay-respects = {
      enable = true;
      enableZshIntegration = true;
    };

    worktrunk = {
      enable = true;
      enableZshIntegration = true;
    };

    nh = {
      enable = true;
      flake = "${config.home.homeDirectory}/.config/nix-darwin";
    };
  };
}
