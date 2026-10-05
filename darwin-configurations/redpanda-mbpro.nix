{ config, ... }: {

  system.primaryUser = "chrisseto";

  nix.enable = true;
  nix.optimise.automatic = true;
  nix.gc.automatic = true;

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.chrisseto = {
    name = "chrisseto";
    home = "/Users/chrisseto";
  };

  # Auto hide the menubar. Sketchybar is better.
  # system.defaults.NSGlobalDomain._HIHideMenuBar = true;
}
