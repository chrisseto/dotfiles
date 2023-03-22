{
  # https://nixos.org/manual/nixpkgs/unstable/#sec-darwin-builder
  # https://nixos.org/manual/nix/stable/advanced-topics/distributed-builds.html
  # https://github.com/NixOS/nix/pull/5990/files
  # https://github.com/NixOS/nixpkgs/blob/99563190d585896d7ddb43ea448a95574dfa2373/nixos/modules/profiles/macos-builder.nix#L159-L168
  # Start builder with `nix run nixpkgs#darwin.builder`
  nixConfig = {
    builders = "ssh-ng://builder@localhost aarch64-linux /etc/nix/builder_ed25519 - - kvm,big-parallel - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUpCV2N4Yi9CbGFxdDFhdU90RStGOFFVV3JVb3RpQzVxQkorVXVFV2RWQ2Igcm9vdEBuaXhvcwo=";
    builders-use-substitutes = true;
  };

  inputs = {
    nixpkgs.url = "nixpkgs";

    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  # https://nixos.wiki/wiki/Flakes
  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-generators,
    nixos-apple-silicon,
    ...
  }: {
    formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.alejandra;
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;

    nixosGenerators = {
      rpi = nixos-generators.nixosGenerate {
        system = "aarch64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./linux-configuration.nix
        ];
        format = "sd-aarch64";
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
