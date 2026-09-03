{ pkgs, inputs, ... }:

let
  matt = "${inputs.mattpocock-skills}/skills";

  # Skills vendored from upstream repos, pinned by flake.lock. Each entry picks
  # one skill dir out of its source repo; bump one with:
  #   nix flake update mattpocock-skills
  upstream = pkgs.linkFarm "upstream-skills" {
    code-review = "${matt}/engineering/code-review";
    codebase-design = "${matt}/engineering/codebase-design";
    diagnosing-bugs = "${matt}/engineering/diagnosing-bugs";
    domain-modeling = "${matt}/engineering/domain-modeling";
    grill-with-docs = "${matt}/engineering/grill-with-docs";
    prototype = "${matt}/engineering/prototype";
    tdd = "${matt}/engineering/tdd";
    triage = "${matt}/engineering/triage";
    grill-me = "${matt}/productivity/grill-me";
    grilling = "${matt}/productivity/grilling";
    handoff = "${matt}/productivity/handoff";
    wait-what = "${matt}/productivity/wait-what";
    writing-for-agents = "${matt}/productivity/writing-for-agents";

    # Other skills I like to keep around
    caveman = "${inputs.caveman-skills}/skills/caveman";
    diagram-design = "${inputs.diagram-design-skills}/skills/diagram-design";
    find-skills = "${inputs.vercel-skills}/skills/find-skills";
    gh-stack = "${inputs.gh-stack-skills}/skills/gh-stack";
    ponytail = "${inputs.ponytail-skills}/skills/ponytail";
    watch = "${inputs.claude-video-skills}/skills/watch";
  };

  skills = pkgs.symlinkJoin {
    name = "agent-skills";
    paths = [
      upstream
      ./skills/_local
      "${inputs.obsidian-skills}/skills"
    ];
  };
in
{
  home.file = {
    ".claude/skills" = {
      source = skills;
      recursive = true;
    };

    ".codex/skills" = {
      source = skills;
      recursive = true;
    };

    ".claude/CLAUDE.md".source = ./agent-instructions.md;
    ".codex/AGENTS.md".source = ./agent-instructions.md;

    ".claude/agents" = {
      source = ./agents;
      recursive = true;
    };
  };

  # pi resolves its agent dir from PI_CODING_AGENT_DIR (see pi.nix).
  xdg.configFile."pi/skills" = {
    source = skills;
    recursive = true;
  };
}
