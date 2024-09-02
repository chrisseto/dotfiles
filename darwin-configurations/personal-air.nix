{ darwin, home-manager, nixpkgs, nixpkgs-unstable, ... }:
let
  system = "aarch64-darwin";
  unstable = import nixpkgs-unstable { inherit system; };
in
darwin.lib.darwinSystem {
  inherit system;

  inputs = { inherit darwin nixpkgs; };
  specialArgs = { inherit unstable; };

  modules = [
    home-manager.darwinModules.home-manager
    ./default.nix
    {
      # nix.linux-builder.enable = false;
      # nix.settings.extra-trusted-users = [ "admin" ];

      users.users.chrisseto = {
        name = "chrisseto";
        home = "/Users/chrisseto";
      };

      home-manager.extraSpecialArgs = { inherit unstable; };
      home-manager.users.chrisseto = {
        imports = [
          ../home-modules/darwin.nix
          ../home-modules/lazy-nvim
          ../homes/common.nix
        ];
      };
    }
  ];
}
