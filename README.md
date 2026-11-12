chrisseto's dotfiles
====================

# Installing

## MacOS
1. Install [nix](https://nixos.org/download.html#nix-install-macos)
1. Install [homebrew](https://brew.sh/)
1. Clone this repo to `~/.nixpkgs`
1. `cd ~/.nixpkgs`
1. Run `nix run .#nix-darwin -- switch --flake .#<profile>`

## Linux (NixOS)
1. Clone this repo to `~/.nixpkgs`
1. Run `nixos-rebuild switch --flake ~/.nixpkgs#<profile>`

## Linux (Home-Manager)
1. Install [Nix](https://nixos.org/download.html#nix-install-macos)
1. Clone this repo to `~/.nixpkgs`
1. Run `nix run .#home-manager -- switch --flake .#gceworker`

## Fonts
I'm a fan of FiraCode's [NerdFont](https://www.nerdfonts.com/font-downloads)

## TODO
- [ ] Fix Application linking on macOS
- [ ] Fix tabs vs spaces on various file types

## Layout

* `configuration` - Nix{OS,-Darwin} Configurations
* `homes` - Home-Manager Configurations
* `packages` - Custom Nix packages

## Useful tools / scripts

### Debugging Closure Sizes

```bash
nix-shell -p nix-tree
nix-tree .#darwinConfigurations.<name>.system
```

### Updating Custom Packages

Packages in `packages/` are exposed as flake outputs (`.#<name>`) and can be
bumped with [nix-update](https://github.com/Mic92/nix-update). It doesn't need
to be installed; run it from the repo root via `nix run`:

```bash
# Source-built packages (e.g. jip): bumps version, hash, and vendorHash.
nix run nixpkgs#nix-update -- --flake jip                  # latest release
nix run nixpkgs#nix-update -- --flake jip --version 1.9.0  # specific version
nix run nixpkgs#nix-update -- --flake jip --build          # bump, then build

# Prebuilt-binary packages (herdr-core, plannotator) pin releases in
# sources.json; -u runs their passthru.updateScript (./update.sh) instead.
nix run nixpkgs#nix-update -- --flake plannotator -u
nix run nixpkgs#nix-update -- --flake plannotator -u --update-script-args 0.28.61
```

The `update.sh` scripts can also be run directly, e.g.
`./packages/plannotator/update.sh [version]`. Set `FORCE=1` to re-fetch hashes
for the current version. Review the result with `git diff` before switching.

### Flake Auto Following

```bash
nix-shell -p flake-edit
flake-edit --diff follow --transitive 2
```
