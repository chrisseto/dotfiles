chrisseto's dotfiles
====================

# Installing

## MacOS
1. Install [nix](https://nixos.org/download.html#nix-install-macos)
1. Install [nix-darwin](https://github.com/LnL7/nix-darwin)
1. Install [home-manager](https://github.com/nix-community/home-manager)
1. Clone this repo to `~/.nixpkgs`
1. Run `darwin-rebuild switch`

## Linux
1. Install [Nix](https://nixos.org/download.html#nix-install-macos)
1. Install [home-manager](https://github.com/nix-community/home-manager)
1. Clone this repo to `~/.nixpkgs`
1. Run `home-manager switch -f ~/.nixpkgs/home.nix`

## Fonts
I'm a fan of FiraCode's [NerdFont](https://www.nerdfonts.com/font-downloads)

## TODO
- [ ] Add support for nix flakes
- [ ] See if there's a good way to manage terminfo with nix
- [ ] Remove the indent from my vim git commit message config
- [ ] Setup https://github.com/glepnir/lspsaga.nvim
- [ ] Make home.nix work on linux machines
- [ ] Convert init.vim to lua

## Add terminfo entries with 256color and italics support.
```
tic ./terminfo/tmux-256color.terminfo
tic ./terminfo/xterm-256color-italic.terminfo
```
