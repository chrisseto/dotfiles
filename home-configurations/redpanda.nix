{ pkgs
, inputs
, ezModules
, ...
}:
let
  unstable = import inputs.nixpkgs-unstable { inherit (pkgs) system; };
in
{
  imports = [
    ezModules.nvim
  ];
  home.packages = [
    pkgs.awscli2
    pkgs.docker
    pkgs.dyff
    pkgs.go-task
    pkgs.google-cloud-sdk
    pkgs.graphviz # Provides `dot` for go tool pprof
    pkgs.k3d
    pkgs.kind
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.kustomize
    pkgs.rustup
    unstable.git-machete
    unstable.grpcurl
    unstable.jira-cli-go # Jira CLI...
    unstable.stern # Kubernetes log tailer
    unstable.teleport # tsh and friends
    unstable.yq-go
  ];
}
