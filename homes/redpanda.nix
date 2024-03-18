{
  pkgs,
  unstable,
  ...
}: let
in {
  home.packages = [
    pkgs.awscli
    pkgs.chart-testing
    pkgs.colima
    pkgs.cue
    pkgs.docker
    pkgs.dyff
    pkgs.go-task
    pkgs.google-cloud-sdk
    pkgs.k3d
    pkgs.kind
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.kustomize
    pkgs.pandoc
    pkgs.yq
  ];
}
