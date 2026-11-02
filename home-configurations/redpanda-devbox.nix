{ pkgs, lib, inputs, ezModules, ... }:
let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{

  imports = [
    ezModules.claude
    ezModules.nvim
    ezModules.pi
    ezModules.redpanda
    inputs.ledecky.homeManagerModules.default
  ];

  services.ledecky.enable = true;

  home.packages = [
    llm-agents.claude-code
    pkgs.asciinema
    pkgs.herdr-core
    pkgs.k3d
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.kustomize
    pkgs.nodejs
    pkgs.plannotator
    pkgs.pnpm
    pkgs.tmux
    unstable.cloc # LoC counting and delta computation
  ];
}
