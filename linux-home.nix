{ config, pkgs, lib, ... }:

{
  imports = [ ./common-home.nix ];

  home.username = "chrisseto";
  home.homeDirectory = "/home/chrisseto";
}
