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
- [ ] Add font support for MacOS
- [ ] See if there's a way to manage iterm2 with nix
- [ ] See if there's a good way to manage terminfo with nix
