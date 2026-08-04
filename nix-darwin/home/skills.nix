{ ... }:

# Global agent skills, managed in ./skills and linked into every agent
# harness's expected skills directory. `recursive = true` symlinks each
# skill individually so agent-installed skills can coexist alongside them.
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
}
