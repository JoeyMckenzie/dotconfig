{ ... }:

{
  home.file.".claude/skills" = {
    source = ./skills;
    recursive = true;
  };

  home.file.".codex/skills" = {
    source = ./skills;
    recursive = true;
  };

  # pi resolves its agent dir from PI_CODING_AGENT_DIR (see pi.nix).
  xdg.configFile."pi/skills" = {
    source = ./skills;
    recursive = true;
  };

  home.file.".claude/agents" = {
    source = ./agents;
    recursive = true;
  };
}
