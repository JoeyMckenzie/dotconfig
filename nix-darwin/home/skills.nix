{ pkgs, inputs, ... }:

let
  skills = pkgs.symlinkJoin {
    name = "agent-skills";
    paths = [
      ./skills
      "${inputs.obsidian-skills}/skills"
    ];
  };
in
{
  home.file.".claude/skills" = {
    source = skills;
    recursive = true;
  };

  home.file.".codex/skills" = {
    source = skills;
    recursive = true;
  };

  # pi resolves its agent dir from PI_CODING_AGENT_DIR (see pi.nix).
  xdg.configFile."pi/skills" = {
    source = skills;
    recursive = true;
  };

  home.file.".claude/CLAUDE.md".source = ./agent-instructions.md;
  home.file.".codex/AGENTS.md".source = ./agent-instructions.md;

  home.file.".claude/agents" = {
    source = ./agents;
    recursive = true;
  };
}
