{ symlinkable, ... }:
{
  programs.fish.shellInit = ''
    set -p fish_function_path ${symlinkable ./fish/functions}
  '';
}
