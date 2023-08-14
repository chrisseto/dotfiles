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

  systemd.user.services.bazel-cache = {
    Unit = {
      Description = "Bazel HTTP/1.1 cache";
      After = ["networking.target"];
      PartOf = [];
    };

    Service = {
      Type = "simple";
      Restart = "always";
      ExecStart = "${pkgs.bazel-remote}/bin/bazel-remote --config_file %C/dev-bazel-remote/config.yml";
      ExecStartPost = "/bin/sh -c 'echo $MAINPID > %C/dev-bazel-remote/.dev-cache.pid'";
      Group = "chrisseto";
      PIDFile = "%C/dev-bazel-remote/.dev-cache.pid";
    };

    Install = {WantedBy = ["default.target"];};
  };
}
