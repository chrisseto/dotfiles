{ pkgs
, unstable
, ...
}: {
  home.packages = [
    pkgs.rustup
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
    pkgs.nodejs_23 # For copilot in nvim
    unstable.stern # Kubernetes log tailer
    unstable.jira-cli-go # Jira CLI...
    unstable.grpcurl
    unstable.stgit
    unstable.teleport # tsh and friends
    unstable.yq-go
  ];
}
