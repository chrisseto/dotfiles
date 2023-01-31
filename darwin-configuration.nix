{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.fd
    pkgs.git
    pkgs.neovim
    pkgs.nixfmt
    pkgs.ripgrep
    pkgs.stow
    pkgs.tmux
    pkgs.vim
  ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;
  programs.bash.enable = true;
  programs.fish.enable = true;

  environment.shells = [ pkgs.fish ];
  environment.loginShell = "/run/current-system/sw/bin/fish";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # Setup faster key repeat than what can be configured with the UI.
  system.defaults.NSGlobalDomain.KeyRepeat = 1;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 12;

  # No more RSI.
  system.keyboard.enableKeyMapping =
    true; # Required to enabled caps lock remap.
  system.keyboard.remapCapsLockToControl = true;
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;

  # Trackpad configuration.
  system.defaults.trackpad.Clicking = true; # enable tap to click.
  system.defaults.trackpad.TrackpadThreeFingerDrag = true;
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" =
    false; # No natural scrolling.

  # Extra configs to make nix nicer to use.
  nix.extraOptions = ''
    extra-platforms = aarch64-darwin x86_64-darwin
    experimental-features = nix-command flakes
  '';


  # The previous iteration of this repo was managed by stow. To ease the
  # transition, use postActivation to install all existing configurations.
  system.activationScripts.postActivation.text = ''
    #! /bin/bash
    set -eo pipefail

    # Create ~/.config to stop stow from trying to manage the entire directory.
    mkdir -p ~/.config

    # Use stow to link all our various dotfiles.
    stow -R fish nvim git tmux
  '';
}
