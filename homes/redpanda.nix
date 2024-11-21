{ pkgs
, unstable
, ...
}:
let
in {

  programs.fish = {
    interactiveShellInit = ''
      fish_add_path $HOME/.rd/bin
    '';
  };

  home.packages = [
    pkgs.awscli2
    pkgs.colima
    pkgs.docker
    pkgs.dyff
    pkgs.git-machete
    pkgs.go-task
    pkgs.google-cloud-sdk
    pkgs.graphviz # Provides `dot` for go tool pprof
    pkgs.k3d
    pkgs.kind
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.kustomize
    unstable.grpcurl # `curl` but for gRPC
    unstable.lima
    unstable.stgit
  ];
}
