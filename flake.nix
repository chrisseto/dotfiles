{
  inputs = {
    nixpkgs.url = "nixpkgs";

    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # https://nixos.wiki/wiki/Flakes
  outputs = {
    self,
    darwin,
    nixpkgs,
    home-manager,
    nixos-apple-silicon,
    ...
  }: {
    formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.alejandra;
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;

    darwinConfigurations = {
      "Chriss-Air" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModules.home-manager
          ./darwin-configuration.nix
        ];
        inputs = {inherit darwin nixpkgs;};
      };
    };

    nixosConfigurations = {
      asahi-mini = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-apple-silicon.nixosModules.apple-silicon-support
          # ./nas.nix
          ./asahi-mini.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # Define a user account. Don't forget to set a password with ‘passwd’.
            users.users.chrisseto = {
              isNormalUser = true;
              home = "/home/chrisseto";
              hashedPassword = "$6$PK.EJqps/uhJSWsM$S1HGVnVQCVIlf.xYNeHjuot2YEzjv4Xy/PLlnyBUxrXo6d/lkxsujjgt7sSnnZ5v8F/eeP.CNMOgGsTL2IN8w0";
              extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
              openssh.authorizedKeys.keys = ["SHA256:OlM7U4J9YBrCbk0zp9CQIvqAB8YLU4XVhD0Jt744Qe0"];
            };

            home-manager.users.chrisseto = import ./linux-home.nix;
          }
        ];
        specialArgs = {
          inherit nixpkgs;
          inherit nixos-apple-silicon;
        };
      };
    };
  };
}
