{ pkgs
, inputs
, ezModules
, ...
}:
let
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{

  imports = [
    ezModules.nvim
    ezModules.claude
    inputs.ledecky.homeManagerModules.default
  ];

  services.ledecky.enable = true;
}
