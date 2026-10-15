{ pkgs, lib, inputs, ezModules, ... }:
let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
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
