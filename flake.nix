{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
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
      url = "github:tpwrules/nixos-apple-silicon/release-2026-07-30";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # https://nixos.wiki/wiki/Flakes
  outputs =
    inputs @ { self
    , agenix
    , darwin
    , flake-parts
    , home-manager
    , nixos-apple-silicon
    , nixpkgs
    , nixpkgs-unstable
    , ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, ... }: {
      systems = [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ];

      imports = [
        inputs.ez-configs.flakeModule
      ];

      ezConfigs = {
        root = builtins.path { path = ./.; name = "source"; };

        globalArgs = { inherit inputs; };

        darwin.hosts = {
          personal-air.userHomeModules = {
            chrisseto = "personal-air";
          };

          redpanda-mbpro.userHomeModules = {
            chrisseto = "redpanda";
          };
        };

        nixos.hosts.asahi-mini.userHomeModules = {
          chrisseto = "ssh";
        };
      };

      flake = { };

      perSystem = { pkgs, lib, system, inputs, inputs', ... }: {
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

    });
}
