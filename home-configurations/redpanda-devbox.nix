{ pkgs, lib, inputs, ezModules, ... }:
let
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
in
{

  imports = [
    ezModules.nvim
    ezModules.claude
  ];

  home.packages = [
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.kustomize
    pkgs.nodejs
    pkgs.pnpm
    pkgs.rustup
    pkgs.tmux
    unstable.claude-code
    unstable.cloc # LoC counting and delta computation
    unstable.git-branchless
  ];
}
