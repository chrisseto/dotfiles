{ config
, pkgs
, ...
}: {
  home.packages = [
    pkgs.reattach-to-user-namespace
  ];
}
