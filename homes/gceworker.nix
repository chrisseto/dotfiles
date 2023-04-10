{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./common.nix];

  home.packages = [
    pkgs.kubectl
  ];

  home.username = "chrisseto";
  home.homeDirectory = "/home/chrisseto";
}
