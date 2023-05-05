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
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
    formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.alejandra;
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    homeConfigurations = {
      gceworker = home-manager.lib.homeManagerConfiguration {
        # TODO don't hardcode system here...
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        modules = [
          ./homes/gceworker.nix
        ];
      };
    };

    darwinConfigurations = {
      "crlMBP-MV7L2CVHJQMTQ0" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModules.home-manager
          ./configurations/darwin.nix
          {
            users.users.chrisseto = {
              name = "chrisseto";
              home = "/Users/chrisseto";
            };

            home-manager.users.chrisseto = import ./homes/darwin.nix;
          }
        ];
        inputs = {inherit darwin nixpkgs;};
      };

      "Chriss-Air" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModules.home-manager
          ./configurations/darwin.nix
          {
            users.users.chrisseto = {
              name = "chrisseto";
              home = "/Users/chrisseto";
            };

            home-manager.users.chrisseto = import ./homes/darwin.nix;
          }
        ];
        inputs = {inherit darwin nixpkgs;};
      };
    };

    nixosConfigurations = {
      asahi-mini = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-apple-silicon.nixosModules.apple-silicon-support
          ./configurations/nas.nix
          ./configurations/asahi-mini.nix
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

            home-manager.users.chrisseto = import ./homes/gceworker.nix;
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
