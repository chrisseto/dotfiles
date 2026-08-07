{ inputs, ... }: {

  system.primaryUser = "chrisseto";

  nix.enable = false;

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.chrisseto = {
    name = "chrisseto";
    home = "/Users/chrisseto";
  };
}
