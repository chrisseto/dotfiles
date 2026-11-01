{ ezModules, inputs, pkgs, config, ... }: {
  imports = [
    inputs.microvm.nixosModules.microvm
  ];

  system.stateVersion = "26.05"; # Did you read the comment?
  networking.hostName = "agent-sandbox";
  nixpkgs.hostPlatform = "aarch64-linux";

  microvm = {
    vcpu = 4;
    mem = 4048;

    balloon = true;

    interfaces = [{
      type = "tap";
      id = "vm-agent-sbx";
      mac = "02:00:00:00:00:01";
    }];

    volumes = [
      { image = "root.img"; mountPoint = "/"; size = 32768; }
      { image = "nix-store.img"; mountPoint = "/nix/.rw-store"; size = 32768; }
    ];
    writableStoreOverlay = "/nix/.rw-store";

    shares = [{
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
      tag = "ro-store";
      proto = "virtiofs";
    }];
  };

  # Allow non-nix compiled binaries to work as expected.
  programs.nix-ld.enable = true;

  services.tailscale.enable = true;

  environment.systemPackages = with pkgs; [
    tailscale
    gcc
    gccStdenv
  ];

  environment.variables = {
    PLANNOTATOR_REMOTE = "1";
    PLANNOTATOR_URL_HOST = "auto";
    BROWSER = "0";
    PLANNOTATOR_SHARE = "disabled";
  };

  networking.firewall = {
    # Allow tailscale to connect freely.
    trustedInterfaces = [ "tailscale0" ];

    allowedUDPPorts = [
      config.services.tailscale.port # tailscale
    ];
  };

  networking.useNetworkd = true;
  systemd.network.networks."20-eth" = {
    matchConfig.MACAddress = "02:00:00:00:00:01";
    networkConfig = {
      Address = "10.100.0.2/24";
      Gateway = "10.100.0.1";
      # NB: Router DNS is on the LAN, which the host blocks.
      DNS = [ "1.1.1.1" "9.9.9.9" ];
    };
  };

  services.openssh.enable = true;

  security.sudo.extraRules = [{
    users = [ "chrisseto" ];
    commands = [
      { command = "ALL"; options = [ "NOPASSWD" ]; }
    ];
  }];

  users.users.chrisseto = {
    isNormalUser = true;
    home = "/home/chrisseto";
    linger = true; # Make the user session linger to keep ledecky running even if the user session is killed.
    shell = pkgs.fish;
    hashedPassword = "$6$PK.EJqps/uhJSWsM$S1HGVnVQCVIlf.xYNeHjuot2YEzjv4Xy/PLlnyBUxrXo6d/lkxsujjgt7sSnnZ5v8F/eeP.CNMOgGsTL2IN8w0";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIClQd+Mx8j4tLqk/a2s705FlLPfEbXbXpMeUCcuwDqZ8"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKn3yk0zGVSxD+S7xjvWD+GNhP938kp21dHgUPNknTN2"
    ];
  };
}
