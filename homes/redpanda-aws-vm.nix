{ 
 pkgs
, ...
}:
{

  home.packages = [
    # pkgs.bazel-remote # An HTTP/1.1 cache for bazel builds
    pkgs.patchelf # Required for --config=crossbuild in CRDB
    pkgs.gnumake
    pkgs.clang
  ];

  # Default user name of the debian AMI.
  home.username = "admin";
  home.homeDirectory = "/home/admin";

  programs.fish = {
    enable = true;

    # Unclear why this is required. It places all nix installed pkgs into
    # $PATH.
    interactiveShellInit = ''
      fish_add_path "$HOME/.nix-profile/bin"
      fish_add_path /nix/var/nix/profiles/default/bin
      '';
    };

  # systemd.user.services.bazel-cache = {
  #   Unit = {
  #     Description = "Bazel HTTP/1.1 cache";
  #     After = [ "networking.target" ];
  #     PartOf = [ ];
  #   };
  #
  #   Service = {
  #     Type = "simple";
  #     Restart = "always";
  #     ExecStart = "${pkgs.bazel-remote}/bin/bazel-remote --config_file %C/dev-bazel-remote/config.yml";
  #     ExecStartPost = "/bin/sh -c 'echo $MAINPID > %C/dev-bazel-remote/.dev-cache.pid'";
  #     Group = "admin";
  #     PIDFile = "%C/dev-bazel-remote/.dev-cache.pid";
  #   };
  #
  #   Install = { WantedBy = [ "default.target" ]; };
  # };
}
