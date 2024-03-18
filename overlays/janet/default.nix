self: super:
let
  janetPackages = super.callPackage ./packages.nix { };
  withPackages = super.callPackage ./with-packages.nix { inherit janetPackages; };
in
{
  inherit janetPackages;
  janet = super.janet // { inherit withPackages; };
}
