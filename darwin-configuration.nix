{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [ pkgs.git pkgs.vim ];

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

  system.defaults.NSGlobalDomain.AppleICUForce24HourTime = true;

  # Enable dark mode UI
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";

  # Dock configuration
  system.defaults.dock.autohide = true;
  system.defaults.dock.mru-spaces = false;
  system.defaults.dock.minimize-to-application = true;
  system.defaults.dock.tilesize = 48;

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

  imports = [ <home-manager/nix-darwin> ];
  users.users.chrisseto = {
    name = "chrisseto";
    home = "/Users/chrisseto";
  };

  /* home-manager.useUserPackages = true; */
  home-manager.users.chrisseto = import ./home.nix;
}
