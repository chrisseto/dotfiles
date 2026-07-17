{ inputs, ... }: {

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.chrisseto = {
    name = "chrisseto";
    home = "/Users/chrisseto";
  };
}
