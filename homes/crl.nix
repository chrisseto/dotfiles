{
  pkgs,
  unstable,
  ...
}: let
in {
  home.packages = [
    (pkgs.google-cloud-sdk.withExtraComponents [pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin])
    pkgs.colima
    pkgs.docker
    pkgs.docker-compose
    pkgs.kubectl
    unstable.duckdb
  ];
}
