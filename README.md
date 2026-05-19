# nixfiles

My personal nix setup for [nix-darwin](https://github.com/nix-darwin/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager) for all the tools and random shit I use on a daily basis:

## Getting started

1. Clone this repository to your XDG config base directory (usually `~/.config`)

```bash
mv ~/.config ~/.config.bak
git clone https://github.com/JoeyMckenzie/.config.git ~/.config
```

2. Install nix via [lix](https://lix.systems/install/)

3. Build with:

```bash
sudo darwin-rebuild switch --flake "$HOME/.config/nix-darwin#$(scutil --get LocalHostName)"
```
