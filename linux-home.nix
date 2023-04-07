{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./common-home.nix];

  home.packages = [
    pkgs.kubectl
  ];

  home.username = "chrisseto";
  home.homeDirectory = "/home/chrisseto";
}
