{
  janet,
  janetPackages,
  stdenv,
  buildEnv,
  makeBinaryWrapper,
  lib,
}: mkSelection: let
  janetEnv = let
    selection = mkSelection janetPackages;
    # Copied from https://github.com/NixOS/nixpkgs/blob/nixos-23.11/pkgs/development/idris-modules/with-packages.nix#L5
    paths = lib.closePropagation selection;
  in
    buildEnv {
      inherit paths;
      name = "janet-packages";
      pathsToLink = ["/lib"];
    };
in
  stdenv.mkDerivation {
    name = "${janet.name}-with-packages";
    nativeBuildInputs = [makeBinaryWrapper];
    buildCommand = ''
      mkdir -p $out/bin
      for i in ${janet}/bin/*; do
        makeWrapper "$i" $out/bin/$(basename "$i") --set JANET_PATH ${janetEnv}/lib
      done
    '';
  }
