default:
    @just --list

# format all nix files in-place
fmt:
    fd -e nix -t f . nix-darwin --exec nixfmt

# check formatting without modifying files
fmt-check:
    fd -e nix -t f . nix-darwin --exec nixfmt --check

# lint with statix
lint:
    statix check nix-darwin

# auto-fix statix issues
lint-fix:
    statix fix nix-darwin

# find dead nix code
dead:
    deadnix nix-darwin

# remove dead nix code
dead-fix:
    deadnix -e nix-darwin

# run the flake's pre-commit check against all files
check:
    nix build ./nix-darwin#checks.aarch64-darwin.pre-commit-check --no-link

# run every auto-fixer: deadnix -> statix -> nixfmt
fix: dead-fix lint-fix fmt

# bump the vendored agent-skill inputs (pass names to bump only some)
skills-update *inputs:
    nix flake update --flake ./nix-darwin {{ if inputs == "" { "claude-video-skills diagram-design-skills gh-stack-skills mattpocock-skills obsidian-skills vercel-skills" } else { inputs } }}
