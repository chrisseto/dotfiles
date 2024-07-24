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
    pkgs.yq
    pkgs.git-machete
    unstable.stgit
  ];
}
