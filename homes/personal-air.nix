{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./darwin.nix];

  home.packages = [
    pkgs.f3d
    pkgs.ghc
    # pkgs.haskell-language-server
    pkgs.haskellPackages.ghcup
  ];
}
