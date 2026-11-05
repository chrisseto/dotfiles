{ pkgs
, lib
, inputs
, ezModules
, symlinkable
, ...
}:
let
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    ezModules.claude
    ezModules.nvim
    ezModules.pi
    ezModules.redpanda
  ];

  programs.fish.shellInit = lib.mkAfter ''
    set -p fish_function_path ${symlinkable ./fish/functions}
  '';

  home.packages = [
    pkgs.awscli2
    pkgs.docker
    pkgs.dyff
    pkgs.go-task
    pkgs.graphviz # Provides `dot` for go tool pprof
    pkgs.herdr-core
    pkgs.k3d
    pkgs.kind
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.kustomize
    pkgs.plannotator
    pkgs.terraform
    unstable.cloc # LoC counting and delta computation
    unstable.grpcurl
    unstable.ssm-session-manager-plugin
    unstable.stern # Kubernetes log tailer
    unstable.teleport # tsh and friends
    unstable.yq-go
  ];

  home.file.".local/bin/herdr-core".source = "${pkgs.herdr-core}/bin/herdr-core";
  home.file.".local/bin/hc".source = "${pkgs.herdr-core}/bin/hc";
}
