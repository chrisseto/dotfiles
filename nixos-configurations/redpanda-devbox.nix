{ lib
, inputs
, pkgs
, modulesPath
, ...
}:
let
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
  };
in
{
  system.stateVersion = "26.05";

  networking.hostName = lib.mkForce "redpanda-devbox";

  imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];

  # Disables cloud init, which indicates that bootstrapping succeeded.
  virtualisation.amazon-init.enable = false;

  fileSystems."/home" = {
    # Must match device name from the volume attachment resource.
    device = "/dev/sdf";
    fsType = "ext4";
    autoFormat = true;
    autoResize = true;
    options = [ "nofail" ];
  };

  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    tmux # Required for running daemons easily
    gcc # Required for treesitter builds.
    unstable.wezterm
  ];

  users.users.chrisseto = {
    shell = pkgs.fish;
    linger = true; # Make the user session linger to keep ledecky running even if the user session is killed.
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKn3yk0zGVSxD+S7xjvWD+GNhP938kp21dHgUPNknTN2"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  # SSH Access without needing ingress.
  services.amazon-ssm-agent.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = lib.mkForce "no";
    };
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];
    max-jobs = "auto";
  };

  # It is a build box on a finite root volume; keep the store from filling it.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.optimise.automatic = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-linux";

  systemd.services.seed-dotfiles =
    let user = "chrisseto"; in
    {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      unitConfig = {
        RequiresMountsFor = "/home/chrisseto";
        ConditionPathExists = "!/home/chrisseto/.nixpkgs/.git";
      };

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        # network-online.target is not a strong guarantee; retry a few times
        # rather than waiting for a reboot.
        Restart = "on-failure";
        RestartSec = "10s";

        User = user;
        Group = "users";

        # Ensures /home/chrisseto exists.
        ExecStartPre = "+${pkgs.coreutils}/bin/install -d -m 0700 -o ${user} -g users /home/${user}";
      };

      path = with pkgs; [
        git
        openssh
      ];

      script = ''
        git clone --branch master https://github.com/chrisseto/dotfiles.git /home/${user}/.nixpkgs
        git -C /home/${user}/.nixpkgs remote set-url origin git@github.com:chrisseto/dotfiles.git
      '';

    };
}
