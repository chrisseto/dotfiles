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
    inputs.ledecky.homeManagerModules.default
  ];

  services.ledecky.enable = true;

  home.shellAliases = {
    git = "git-branchless wrap --";
  };

  home.packages = [
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.kustomize
    pkgs.nodejs
    pkgs.pnpm
    pkgs.tmux
    unstable.claude-code
    unstable.cloc # LoC counting and delta computation
    inputs.git-branchless.packages.${pkgs.system}.git-branchless
  ];
}
