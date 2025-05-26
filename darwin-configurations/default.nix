{ config
, pkgs
, unstable
, ...
}:
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [ ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  nix.enable = false;
  # Allow my user to run remote builds.
  nix.settings.trusted-users = [ "root" "chrisseto" ];
  # nix.enable = true;
  # nix.channel.enable = false;
  # Automatically clean up the nix store to save diskspace.
  # nix.optimise.automatic = true;
  # nix.gc.automatic = true;

  # Extra configs to make nix nicer to use.
  nix.extraOptions = ''
    extra-platforms = aarch64-darwin x86_64-darwin
    experimental-features = nix-command flakes
  '';

  nixpkgs.config.allowUnfree = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;
  programs.bash.enable = true;
  programs.fish.enable = true;

  environment.shells = [ pkgs.fish ];

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
  # Display App Switcher on all monitors https://superuser.com/questions/670252/cmdtab-app-switcher-is-on-the-wrong-monitor
  system.defaults.dock.appswitcher-all-displays = true;

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

  fonts = {
    packages = [
      pkgs.fira-code
      unstable.nerd-fonts.fira-code
    ];
  };

  # Use Homebrew to install casks and mas for app store apps as they'll
  # correctly populate /Applications. Nix is still struggling to find a good
  # solution here https://github.com/LnL7/nix-darwin/issues/214
  homebrew = {
    enable = true;

    brews = [
      "mas" # CLI to allow nix to install apps from the MacOS AppStore https://github.com/mas-cli/mas
    ];

    casks = [
      "bettertouchtool" # Hotkey manager. Might be nice to replace with a fully tiling window manager. https://folivora.ai/
      "brave-browser" # Browser of choice.
      "logseq" # Note App of choice.
      "monitorcontrol" # Allows control over external monitors with builtin buttons (Brightness, Volume, etc). https://github.com/MonitorControl/MonitorControl
      "nikitabobko/tap/aerospace" # i3 like tiling window manager for macOS.
      "spotify"
      "todoist"
      "wezterm" # Terminal Emulator. https://wezfurlong.org/wezterm/index.html
    ];

    masApps = {
      "Tailscale" = 1475387142; # VPN access. Also available as a cask. https://tailscale.com/
      "Email Me" = 1090744587; # Cute app for quickly sending notes to an email address. https://www.emailmeapp.net/faq
    };
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
