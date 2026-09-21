{ pkgs
, inputs
, ezModules
, ...
}:
let
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
in
{

  imports = [
    ezModules.nvim
    ezModules.claude
    inputs.ledecky.homeManagerModules.default
  ];

  services.ledecky.enable = true;

  home.shellAliases = {
    git = "git-branchless wrap --";
  };

  home.packages = [
    unstable.git-branchless
  ];
}
