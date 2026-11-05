# Packages defined in ../../packages, added to pkgs.
final: _prev: {
  herdr-core = final.callPackage ../../packages/herdr-core/package.nix { };
  plannotator = final.callPackage ../../packages/plannotator/package.nix { };
}
