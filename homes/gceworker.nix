{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./common.nix];

  home.packages = [
    pkgs.bazel-remote # An HTTP/1.1 cache for bazel builds
    pkgs.kubectl
    pkgs.patchelf # Required for --config=crossbuild in CRDB
  ];

  home.username = "chrisseto";
  home.homeDirectory = "/home/chrisseto";

  # systemd.user.services.bazel-cache = {
  #   Unit = {
  #     Description = "Bazel HTTP/1.1 cache";
  #     After = ["networking.target"];
  #     PartOf = [];
  #   };

  #   Service = {
  #     Type = "simple";
  #     Restart = "always";
  #     ExecStart = "${pkgs.bazel-remote}/bin/bazel-remote --dir %C/bazel-remote";
  #     Environment = [
  #       "BAZEL_REMOTE_HTTP_ADDRESS=localhost:9867"
  #       "BAZEL_REMOTE_MAX_SIZE=16"
  #     ];
  #   };

  #   Install = {WantedBy = ["default.target"];};
  # };
}
