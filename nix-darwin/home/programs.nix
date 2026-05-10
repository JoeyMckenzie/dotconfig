{ lib, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Joey McKenzie";
      http.postBuffer = 1048576000;
      merge.conflictStyle = "zdiff3";
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      version = "1";
      git_protocol = "https";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
      };
    };
  };

  programs.claude-code = {
    enable = true;
    settings = {
      hooks = {
        PostToolUse = [
          {
            matcher = "Edit|MultiEdit|Write";
            hooks = [
              {
                type = "command";
                command = ''p="$(jq -r '.tool_input.file_path')"; case "$p" in *.nix) nix fmt "$p" ;; esac'';
              }
            ];
          }
        ];
      };
    };
  };

  programs.broot = {
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

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      dark = true;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = lib.importTOML ./starship.toml;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.pay-respects = {
    enable = true;
    enableZshIntegration = true;
  };
}
