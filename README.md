chrisseto's dotfiles
====================

# Installing

## MacOS
1. Install [nix](https://nixos.org/download.html#nix-install-macos)
1. Install [nix-darwin](https://github.com/LnL7/nix-darwin)
1. Install [home-manager](https://github.com/nix-community/home-manager)
1. Clone this repo to `~/.nixpkgs`
1. Run `darwin-rebuild switch --flake ~/.nixpkgs#`

## Linux
1. Install [Nix](https://nixos.org/download.html#nix-install-macos)
1. Install [home-manager](https://github.com/nix-community/home-manager)
1. Clone this repo to `~/.nixpkgs`
1. Run `home-manager switch -f ~/.nixpkgs/linux-home.nix`

## Fonts
I'm a fan of FiraCode's [NerdFont](https://www.nerdfonts.com/font-downloads)

## TODO
- [ ] Remove the indent from my vim git commit message config
- [ ] Convert init.vim to lua
- [ ] Move dotfiles out of hidden directories
- [ ] Fix Application linking on macOS
- [ ] Fix tabs vs spaces on various file types
- [ ] Upgrade to a treesitter based commenting tool
- [ ] Configure spell check on treesitter comments
- [ ] Move vim plugin management to nix flakes so that plugin repos are pinned to SHAs and easily updatable.
- [ ] Consider configuring BTT with nix as it seems to be the consistent answer for many tweaks and bindings.
- [ ] Add a darwin configuration for work MBP

## Layout

* `configuration` - Nix{OS,-Darwin} Configurations
* `homes` - Home-Manager Configurations
* `packages` - Custom Nix packages
