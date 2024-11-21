{ config
, pkgs
, lib
, ...
}:
{
  imports = [ ./common.nix ];

  home.packages = [
    pkgs.wezterm
  ];

  home.username = "chrisseto";
  home.homeDirectory = "/home/chrisseto.linux";
}
