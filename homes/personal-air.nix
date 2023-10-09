{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = [
    pkgs.colima
    pkgs.docker
    pkgs.k3d
    pkgs.kubectl
    pkgs.nodePackages.typescript
    pkgs.nodePackages.typescript-language-server
  ];
}
