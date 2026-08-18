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

  xdg.configFile."pi/skills" = {
    source = ./skills;
    recursive = true;
  };

  home.file.".claude/CLAUDE.md".source = ./agent-instructions.md;
  home.file.".codex/AGENTS.md".source = ./agent-instructions.md;
  home.file.".claude/agents" = {
    source = ./agents;
    recursive = true;
  };
}
