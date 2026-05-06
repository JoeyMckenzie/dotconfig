# Shared devenv (`~/.config/devenv`)

A long-running set of dev services (Postgres, MySQL, Redis, Mailpit, Caddy, dnsmasq) plus a few helper scripts. Project repos ship their own `devenv.nix` (see `examples/laravel.devenv.nix`) that talks to these services — they don't import this one.

## One-time machine setup

```bash
# nix + devenv (per devenv docs)

# direnv integration
mkdir -p ~/.config/direnv
devenv direnvrc > ~/.config/direnv/direnvrc
direnv allow ~/.config/devenv

# (optional) speed up cold builds
cachix use devenv

# bring services up
cd ~/.config/devenv && devenv up -d
```

`*.test` resolution: Caddy serves on `:8443`, dnsmasq answers `*.test → 127.0.0.1` on port 8053. Point the system resolver at it (macOS: `/etc/resolver/test` containing `nameserver 127.0.0.1` + `port 8053`).

## Per-project bootstrap

```bash
cp ~/.config/devenv/examples/laravel.devenv.nix /path/to/project/devenv.nix
# edit slug + dbDriver at the top

# register a DB user (idempotent)
register-project myapp                # postgres (default)
register-project myapp --db mysql     # mysql
register-project myapp --db sqlite    # sqlite (no-op, kept for symmetry)
register-project myapp --db both      # both servers
```

- **Postgres** gets a template DB `<slug>_main` cloned per worktree on shell entry.
- **MySQL** creates a user only — per-worktree DBs are created empty on shell entry; run migrations once.
- **SQLite** needs no provisioning — the project's `enterShell` creates `database/database.sqlite` if absent. Per-worktree isolation is automatic since the file lives in the repo.

## Per-worktree bootstrap

```bash
write-site myapp main 8000 5173    # writes sites/myapp-main.caddy
reload-caddy                       # POSTs Caddyfile to admin API
```

Then `https://myapp-main.test:8443` reverse-proxies to the app + Vite. Multiple worktrees coexist via the per-worktree `.devenv-index` file (offsets app/Vite/Xdebug ports + Redis DB index).

## File map

| Path                          | Role                                                    |
| ----------------------------- | ------------------------------------------------------- |
| `devenv.nix`                  | Shared services (Postgres, MySQL, Redis, Mailpit, Caddy, dnsmasq) |
| `tools.nix`                   | Common CLI tools, imported by both shared & project     |
| `Caddyfile`                   | Top-level Caddy config; imports `sites/*.caddy`         |
| `bin/register-project`        | Provision DB user/role for a project (`--db` flag)      |
| `bin/write-site`              | Generate per-worktree Caddy fragment                    |
| `bin/reload-caddy`            | POST Caddyfile to admin API (works outside the shell)   |
| `examples/laravel.devenv.nix` | Template for project-level `devenv.nix`                 |
| `sites/`                      | Generated Caddy fragments (gitignored except `example`) |

## Troubleshooting

- **`use_devenv: command not found`** — `~/.config/direnv/direnvrc` missing. Re-run the one-time setup above.
- **`*.test` doesn't resolve** — dnsmasq isn't running (`devenv up`?), or system resolver isn't pointed at it.
- **Caddy 502 on a new worktree** — forgot `reload-caddy` after `write-site`.
- **Project shell can't reach Postgres/MySQL** — services aren't up; `cd ~/.config/devenv && devenv up -d`.
- **MySQL EOL errors on rebuild** — nixpkgs drops EOL versions; bump `pkgs.mysql84` to the current LTS in `devenv.nix`.
