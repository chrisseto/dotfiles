{ pkgs, symlinkable, ... }:
{

  home.packages = [
    pkgs.bazelisk
  ];

  programs.fish.shellInit = ''
    set -p fish_function_path ${symlinkable ./fish/functions}
  '';
}
