chrisseto's dotfiles
====================

# Installing

## MacOS
1. Install [nix](https://nixos.org/download.html#nix-install-macos)
1. Install [nix-darwin](https://github.com/LnL7/nix-darwin)
1. Install [home-manager](https://github.com/nix-community/home-manager)
1. Clone this repo to `~/.nixpkgs`
1. Run `darwin-rebuild switch --flake ~/.nixpkgs#`

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
- [ ] Configure spell check on treesitter comments
- [ ] Consider configuring BTT with nix as it seems to be the consistent answer for many tweaks and bindings.
- [ ] Add a darwin configuration for work MBP
- [ ] Make darwin configs load via `nix run`

## Layout

* `configuration` - Nix{OS,-Darwin} Configurations
* `homes` - Home-Manager Configurations
* `packages` - Custom Nix packages
