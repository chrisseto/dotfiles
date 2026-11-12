# Packages defined in ../../packages, added to pkgs.
# Takes flake inputs for packages that need something newer than stable nixpkgs.
inputs: final: _prev:
let
  unstable = inputs.nixpkgs-unstable.legacyPackages.${final.stdenv.hostPlatform.system};
in
{
  herdr-core = final.callPackage ../../packages/herdr-core/package.nix { };
  # jip (and its deps) require a newer Go patch release than stable ships.
  jip = final.callPackage ../../packages/jip/package.nix { inherit (unstable) buildGoModule; };
  plannotator = final.callPackage ../../packages/plannotator/package.nix { };
}
