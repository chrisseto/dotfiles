{
  inputs = {
    nixpkgs.url = "nixpkgs";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    ez-configs.url = "github:ehllie/ez-configs";

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

    extra-container = {
      url = "github:erikarvstedt/extra-container";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # https://nixos.wiki/wiki/Flakes
  outputs =
    inputs @ { self
    , agenix
    , darwin
    , extra-container
    , flake-parts
    , home-manager
    , nixos-apple-silicon
    , nixpkgs
    , nixpkgs-unstable
    , ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, ... }: {
      systems = [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ];

      # TODO: Configure ez-configs to split up configurations.
      # imports = [
      #   inputs.ez-configs.flakeModule
      # ];
      #
      # ezConfigs = {
      #   root = ./.;
      #   globalArgs = {inherit inputs;};
      # };

      perSystem = { pkgs, lib, system, inputs', ... }: {
        formatter = pkgs.nixpkgs-fmt;

        packages =
          {
            # Packages to be available (via nix run .#<name>) on all OSes.
          } // (lib.optionalAttrs pkgs.stdenv.isLinux {
            # Linux will either be nixOS or home-manager only.
            home-manager = inputs'.home-manager.packages.default;
          }) // (lib.optionalAttrs pkgs.stdenv.isDarwin {
            # Darwin is always nix-darwin.
            nix-darwin = inputs'.darwin.packages.default;
          });
      };

      flake = {
        homeConfigurations =
          # let
          #   # TODO don't hardcode system here either...
          #   system = "x86_64-linux";
          #   pkgs = import nixpkgs { inherit system; };
          #   unstable = import nixpkgs-unstable { inherit system; };
          # in
          {
            # gceworker = home-manager.lib.homeManagerConfiguration {
            #   inherit pkgs;
            #   extraSpecialArgs = { inherit unstable; };
            #
            #   modules = [
            #     ./homes/common.nix
            #     ./homes/crl.nix
            #     ./homes/gceworker.nix
            #   ];
            # };

            redpanda-lima-vm =
              let
                system = "aarch64-linux";
                pkgs = import nixpkgs { inherit system; };
                unstable = import nixpkgs-unstable { inherit system; };
              in
              home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                extraSpecialArgs = { inherit unstable; };

                modules = [
                  ./homes/common.nix
                  ./home-modules/nvim.nix
                  ./homes/redpanda-lima-vm.nix
                ];
              };
          };

        darwinConfigurations = {
          "redpanda-mbpro" = import ./darwin-configurations/redpanda-mbpro.nix {
            inherit darwin nixpkgs home-manager nixpkgs-unstable;
          };

          "Chriss-Air" = import ./darwin-configurations/personal-air.nix {
            inherit darwin nixpkgs home-manager nixpkgs-unstable;
          };
        };

        nixosConfigurations = {
          asahi-mini =
            let
              system = "aarch64-linux";
              pkgs = import nixpkgs { inherit system; };
              unstable = import nixpkgs-unstable { inherit system; };
            in
            nixpkgs.lib.nixosSystem {
              inherit system;

              modules = [
                agenix.nixosModules.default
                home-manager.nixosModules.home-manager
                nixos-apple-silicon.nixosModules.apple-silicon-support
                extra-container.nixosModules.default
                ./configurations/nas.nix
                ./configurations/memento.nix
                ./configurations/asahi-mini.nix
                ./nixos-modules/silverbullet
                ./nixos-modules/home-assistant.nix
                {
                  home-manager.useUserPackages = true;

                  # Define a user account. Don't forget to set a password with ‘passwd’.
                  users.users.chrisseto = {
                    isNormalUser = true;
                    home = "/home/chrisseto";
                    hashedPassword = "$6$PK.EJqps/uhJSWsM$S1HGVnVQCVIlf.xYNeHjuot2YEzjv4Xy/PLlnyBUxrXo6d/lkxsujjgt7sSnnZ5v8F/eeP.CNMOgGsTL2IN8w0";
                    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
                    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIClQd+Mx8j4tLqk/a2s705FlLPfEbXbXpMeUCcuwDqZ8" ];
                  };

                  home-manager.extraSpecialArgs = { inherit unstable; };

                  home-manager.users.chrisseto = {
                    imports = [
                      ./homes/common.nix
                      ./homes/asahi-mini.nix
                      ./home-modules/nvim.nix
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
    });
}
