{ config
, pkgs
, ...
}:
let
  hammerspoon = pkgs.callPackage ../packages/hammerspoon.nix { };
in
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [ hammerspoon ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
  nixpkgs.config.allowUnfree = true;

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

  # Automatically clean up the nix store to save diskspace.
  nix.settings.auto-optimise-store = true;
  # Allow my user to run remote builds.
  nix.settings.trusted-users = [ "root" ];

  fonts = {
    fontDir.enable = true;
    fonts = [ (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; }) ];
  };

  # Nix-darwin does not link installed applications to the user environment. This means apps will not show up
  # in spotlight, and when launched through the dock they come with a terminal window. This is a workaround.
  # Upstream issue: https://github.com/LnL7/nix-darwin/issues/214
  # system.activationScripts.applications.text = let
  #   username = "chrisseto";
  # in pkgs.lib.mkForce ''
  #   echo "setting up ~/Applications..." >&2
  #   applications="$HOME/Applications"
  #   nix_apps="$applications/Nix Apps"

  #   # Needs to be writable by the user so that home-manager can symlink into it
  #   if ! test -d "$applications"; then
  #       mkdir -p "$applications"
  #       chown ${username}: "$applications"
  #       chmod u+w "$applications"
  #   fi

  #   # Delete the directory to remove old links
  #   rm -rf "$nix_apps"
  #   mkdir -p "$nix_apps"
  #   find ${config.system.build.applications}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
  #       while read src; do
  #           # Spotlight does not recognize symlinks, it will ignore directory we link to the applications folder.
  #           # It does understand MacOS aliases though, a unique filesystem feature. Sadly they cannot be created
  #           # from bash (as far as I know), so we use the oh-so-great Apple Script instead.
  #           /usr/bin/osascript -e "
  #               set fileToAlias to POSIX file \"$src\"
  #               set applicationsFolder to POSIX file \"$nix_apps\"
  #               tell application \"Finder\"
  #                   make alias file to fileToAlias at applicationsFolder
  #                   # This renames the alias; 'mpv.app alias' -> 'mpv.app'
  #                   set name of result to \"$(rev <<< "$src" | cut -d'/' -f1 | rev)\"
  #               end tell
  #           " 1>/dev/null
  #       done
  # '';
}
