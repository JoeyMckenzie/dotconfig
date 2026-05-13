# nix-darwin setup on a fresh Mac

End-to-end runbook for taking a fresh (or messy) macOS box to the same state
as the `personal` host, via `darwin-rebuild switch --flake .#<host>`. Written
with the work laptop in mind, but applies to any new machine.

Plan ~1–2 hours. The first build is the slow part (large closure download).

---

## Phase 0 — Pre-flight on the new machine

Things to verify or have ready before you start, especially on a corp-managed
laptop:

- **MDM / IT policy.** Nix install needs `sudo`, creates `/nix`, and writes to
  `/etc/synthetic.conf`. If Jamf/Kandji/Mosyle blocks any of that, the installer
  stalls on the synthetic firmlink step.
- **EDR (CrowdStrike, SentinelOne).** Won't block, but will slow every rebuild
  by scanning the Nix store.
- **SSO-locked apps.** 1Password, Slack, Zoom will install via Homebrew casks
  but need separate auth.
- **Anything important outside `nix-darwin/` under `~/.config/`** — back it up.
  The clone will replace `~/.config`.

---

## Phase 1 — Snapshot current state (so you can grep it later)

Even on a fresh machine this is cheap; on a dirty one it's the safety net.

```bash
mkdir -p ~/pre-nix-snapshot && cd ~/pre-nix-snapshot
brew bundle dump --force --file=./Brewfile 2>/dev/null
brew list --cask > ./casks.txt 2>/dev/null
brew list -1 > ./formulae.txt 2>/dev/null
ls -la ~/.cargo/bin/ > ./cargo-bins.txt 2>/dev/null
ls -la ~/go/bin/ > ./go-bins.txt 2>/dev/null
ls -la ~/.bun/install/global/node_modules/ > ./bun-globals.txt 2>/dev/null
{ command -v npm >/dev/null && npm ls -g --depth=0; } > ./npm-globals.txt 2>/dev/null
```

After everything is up and running, diff against the new setup. Anything you
miss either gets added to the flake (push from personal → pull on work → `drs`)
or installed per-project via `devenv`.

---

## Phase 2 — Spring cleaning (skip on a truly fresh machine)

Order matters — uninstall language toolchains *before* brew, since some
(`rustup`) drop binaries into `/opt/homebrew`.

```bash
# Rust toolchain (clears ~/.cargo, ~/.rustup, removes shims)
rustup self uninstall   # interactive — answer "y"

# Go workspace
rm -rf ~/go ~/.go-version

# Bun
rm -rf ~/.bun

# NPM / Node version managers
rm -rf ~/.npm ~/.nvm

# PHP / Composer / Herd
rm -rf ~/.composer ~/.herd ~/Library/Application\ Support/Herd

# Other version managers
rm -rf ~/.local/share/mise ~/.local/state/mise ~/.mise ~/.asdf ~/.pyenv ~/.rbenv

# Nuke Homebrew entirely — nix-homebrew will reinstall it cleanly
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
sudo rm -rf /opt/homebrew
```

Replace `~/.config` so the clone target is clean:

```bash
mv ~/.config ~/.config.before-nix
```

Optional — clean dotfiles in `$HOME` that home-manager will own (otherwise it
backs them up as `*.hm-backup`):

```bash
for f in ~/.zshrc ~/.zshenv ~/.zprofile ~/.gitconfig; do
  [ -e "$f" ] && mv "$f" "$f.before-nix"
done
```

Check for the Herd-era resolver file (would block the first build):

```bash
ls /etc/resolver/test 2>/dev/null && \
  sudo mv /etc/resolver/test /etc/resolver/test.before-nix-darwin
```

---

## Phase 3 — Install Nix (bootstrap)

You need *some* Nix to evaluate the flake; the flake will swap it for Lix on
the first switch. Use the Determinate/upstream installer — **do not** run the
Lix installer here. nix-darwin manages `nix.package` and will overwrite a
script-installed Lix on every rebuild, leaving you stuck on CppNix.

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Open a new terminal so the Nix shell hooks load. The flake pulls Lix in via
`inputs.lix-module.darwinModules.lixFromNixpkgs`, so after Phase 4's first
switch:

```bash
nix --version   # → "nix (Lix, like Nix) 2.x.x"
```

---

## Phase 4 — Clone the flake and run the first build

```bash
git clone https://github.com/JoeyMckenzie/dotfiles.git ~/.config
cd ~/.config/nix-darwin
nix run nix-darwin -- switch --flake .#work   # use .#personal on personal box
```

The first build will:

1. Pull and build the system closure (slow — many minutes).
2. Install Homebrew under `/opt/homebrew` via `nix-homebrew`, then all casks
   from `darwin/homebrew.nix` + the host file (work adds Slack & Zoom).
3. Set `hostname` and `LocalHostName` to `work` (or `personal`).
4. Configure `*.test` resolver via dnsmasq + `/etc/resolver/test`.
5. Install MySQL / Redis / Caddy / Mailpit as launchd jobs.
6. Symlink zsh/git/starship/atuin/btop/etc. configs from the Nix store into
   `~/.config/`.

When it finishes, **quit and reopen the terminal** so the new zsh loads with
starship, atuin, aliases, etc. Confirm:

```bash
type drs                       # → alias to sudo darwin-rebuild switch --flake … #$(scutil --get LocalHostName)
scutil --get LocalHostName     # → "work" or "personal"
drs                            # rebuild idempotently — should be a no-op the second time
```

From here on, `drs` works on either host.

---

## Phase 5 — Manual auth (can't be flake-managed)

```bash
gh auth login                                  # GitHub CLI
ssh-keygen -t ed25519 -C "<email>"             # or import existing keys via 1Password
claude                                         # walks through Claude Code auth
atuin login -u <username>                      # only if you sync shell history
```

Then GUI-launch and sign in:

- **1Password** (work + personal accounts)
- **TwinGate** (VPN)
- **Slack**, **Zoom**, **Notion**, **Linear**, **Raycast**

The first time you add a real `*.test` site under `~/.config/caddy/sites/`,
run once to install Caddy's local CA into the macOS keychain:

```bash
sudo caddy trust
sudo launchctl kickstart -k system/org.nixos.caddy
```

---

## Phase 6 — Parity check

```bash
launchctl list | rg -i 'caddy|mysql|redis|mailpit'   # all four present, status not "-"
dscacheutil -q host -a name foo.test                  # → 127.0.0.1
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8025   # mailpit → 200
which php bun go cargo claude lazygit                 # all under /run/current-system/ or ~/.nix-profile/
```

Cross-reference `~/pre-nix-snapshot/` for anything missed.

---

## Notes & sharp edges

- **`homebrew.cleanup = "none"`** in `darwin/homebrew.nix`. Manually
  `brew install`ed packages persist across rebuilds. Good for experimentation,
  bad for parity. Flip to `"uninstall"` if you want the flake to be strict.
- **Linear cask** is declared as `linear-linear` (the legacy Homebrew name).
  It auto-aliases to `linear` and still works; can swap to plain `linear` if
  Homebrew ever drops the alias.
- **Per-project dev tooling** (PHP versions, Node, services) belongs in each
  project's `devenv.nix`, not this flake. Globals are intentionally minimal:
  rustup, go, bun, python313, uv, php84.
- **Initial bootstrap on a new host** must use the full
  `--flake .#<host>` form. `drs` only works after the first rebuild has set
  the local hostname.
- **Project repos** (`~/code/`, `~/Projects/`, etc.) are yours to re-clone.
  This setup doesn't touch them.

---

## If the first build fails

Common failure modes seen in the personal-machine migration (`REVIEW_HANDOFF.md`):

| Symptom | Fix |
| --- | --- |
| `/etc/resolver/test exists, not managed by nix-darwin` | `sudo mv /etc/resolver/test /etc/resolver/test.before-nix-darwin` and retry |
| Stale Homebrew tap collision | `sudo rm -rf /opt/homebrew/Library/Taps` (clones reinstall) |
| Cask download 404 | Check the cask name on `brew info --cask <name>` — Homebrew sometimes renames |
| `darwin-rebuild: command not found` after install | Open a new terminal — PATH isn't updated mid-session |

Otherwise: paste the tail of the failed `darwin-rebuild` output into a fresh
Claude session along with the relevant flake files.
