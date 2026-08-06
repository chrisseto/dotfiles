{ ... }: {

  nix.enable = true;
  nix.optimise.automatic = true;
  nix.gc.automatic = true;

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.chrisseto = {
    name = "chrisseto";
    home = "/Users/chrisseto";
  };
}
