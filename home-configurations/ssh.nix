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
  ];

  home.packages = [
    unstable.claude-code
    unstable.bun
  ];
}
