{ darwin, home-manager, nixpkgs, nixpkgs-unstable, ... }:
let
  system = "aarch64-darwin";
  unstable = import nixpkgs-unstable { inherit system; };
in
darwin.lib.darwinSystem {
  inherit system;

  modules = [
    home-manager.darwinModules.home-manager
    ./default.nix
    {
      users.users.chrisseto = {
        name = "chrisseto";
        home = "/Users/chrisseto";
      };

      home-manager.extraSpecialArgs = { inherit unstable; };
      home-manager.users.chrisseto = {
        imports = [
          ../homes/common.nix
          ../homes/darwin.nix
          ../homes/personal-air.nix
        ];
      };
    }
  ];
  inputs = { inherit darwin nixpkgs; };
};
