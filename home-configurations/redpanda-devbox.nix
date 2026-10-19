{ pkgs, lib, inputs, ezModules, ... }:
let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{

  imports = [
    ezModules.nvim
    ezModules.claude
    inputs.ledecky.homeManagerModules.default
  ];

  services.ledecky.enable = true;

  # Only used by `apropos`; rebuilt on every change to home.packages.
  programs.man.generateCaches = false;

  home.packages = [
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.kustomize
    pkgs.nodejs
    pkgs.pnpm
    pkgs.tmux
    unstable.cloc # LoC counting and delta computation
    llm-agents.claude-code
  ];
}
