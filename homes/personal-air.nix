{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./darwin.nix];

  home.packages = [ ];
}
