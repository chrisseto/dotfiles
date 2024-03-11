{
  inputs = {
    nixpkgs.url = "nixpkgs";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.darwin.follows = "darwin";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    agenix,
    darwin,
    home-manager,
    nixos-apple-silicon,
    nixpkgs,
    nixpkgs-unstable,
    ...
  }: {
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
    formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.alejandra;
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    packages.aarch64-darwin.nix-darwin = darwin.packages.aarch64-darwin.default;

    packages.x86_64-linux.home-manager = home-manager.packages.x86_64-linux.default;

    homeConfigurations = let
      # TODO don't hardcode system here either...
      system = "x86_64-linux";
      pkgs = import nixpkgs {inherit system;};
      unstable = import nixpkgs-unstable {inherit system;};
    in {
      gceworker = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {inherit unstable;};

        modules = [
          ./homes/common.nix
          ./homes/crl.nix
          ./homes/gceworker.nix
        ];
      };
    };

    darwinConfigurations = let
      system = "aarch64-darwin";
      unstable = import nixpkgs-unstable {inherit system;};
    in {
      "redpanda-mbpro" = darwin.lib.darwinSystem {
        inherit system;

        modules = [
          home-manager.darwinModules.home-manager
          ./configurations/darwin.nix
          {
            users.users.chrisseto = {
              name = "chrisseto";
              home = "/Users/chrisseto";
            };

            home-manager.extraSpecialArgs = {inherit unstable;};
            home-manager.users.chrisseto = {
              imports = [
                ./homes/common.nix
                ./homes/darwin.nix
                ./homes/redpanda.nix
              ];
            };
          }
        ];
      };

      "crlMBP-MV7L2CVHJQMTQ0" = darwin.lib.darwinSystem {
        inherit system;

        modules = [
          home-manager.darwinModules.home-manager
          ./configurations/darwin.nix
          {
            users.users.chrisseto = {
              name = "chrisseto";
              home = "/Users/chrisseto";
            };

            home-manager.extraSpecialArgs = {inherit unstable;};
            home-manager.users.chrisseto = {
              imports = [
                ./homes/common.nix
                ./homes/darwin.nix
                ./homes/crl.nix
              ];
            };
          }
        ];
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

            home-manager.extraSpecialArgs = {inherit unstable;};
            home-manager.users.chrisseto = {
              imports = [
                ./homes/common.nix
                ./homes/darwin.nix
                ./homes/personal-air.nix
              ];
            };
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
          ./configurations/memento.nix
          ./configurations/asahi-mini.nix
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;

            # Define a user account. Don't forget to set a password with ‘passwd’.
            users.users.chrisseto = {
              isNormalUser = true;
              home = "/home/chrisseto";
              hashedPassword = "$6$PK.EJqps/uhJSWsM$S1HGVnVQCVIlf.xYNeHjuot2YEzjv4Xy/PLlnyBUxrXo6d/lkxsujjgt7sSnnZ5v8F/eeP.CNMOgGsTL2IN8w0";
              extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
              openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIClQd+Mx8j4tLqk/a2s705FlLPfEbXbXpMeUCcuwDqZ8"];
            };

            age.secrets = {
              git-credentials = {
                file = ./secrets/asahi-mini/git-credentials.age;
                owner = "chrisseto";
                mode = "400";
              };
            };

            home-manager.users.chrisseto = {
              imports = [
                ./homes/common.nix
                ./homes/asahi-mini.nix
              ];
            };
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
