{ darwin, home-manager, nixpkgs-unstable, ... }:
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
          ../home-modules/nvim.nix
          ../homes/common.nix
          ../homes/redpanda.nix
        ];
      };
    }
  ];

}
