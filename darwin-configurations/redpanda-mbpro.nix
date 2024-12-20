{ darwin, home-manager, nixpkgs, nixpkgs-unstable, ... }:
let
  system = "aarch64-darwin";
  unstable = import nixpkgs-unstable { inherit system; };
in
darwin.lib.darwinSystem {
  inherit system;

  inputs = { inherit darwin nixpkgs; };
  specialArgs = { inherit nixpkgs-unstable; inherit unstable; };

  modules = [
    home-manager.darwinModules.home-manager
    ./default.nix
    {
      users.users.chrisseto = {
        name = "chrisseto";
        home = "/Users/chrisseto";
      };

      home-manager.extraSpecialArgs = { inherit nixpkgs-unstable; inherit unstable; };
      home-manager.users.chrisseto = {
        imports = [
          ../home-modules/darwin.nix
          # ../home-modules/lazy-nvim # Not quite ready for prime time.
          ../home-modules/nvim.nix
          ../homes/common.nix
          ../homes/redpanda.nix
        ];
      };
    }
  ];

}
