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

# Release static config from Home Manager, then move it into this dotfiles repo.
migrate-static-configs:
    sudo darwin-rebuild switch --flake "$HOME/.config/nix-darwin#$(scutil --get LocalHostName)"
    ./nix-darwin/scripts/migrate-static-configs

# run every auto-fixer: deadnix -> statix -> nixfmt
fix: dead-fix lint-fix fmt
