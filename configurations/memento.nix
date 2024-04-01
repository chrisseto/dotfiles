{ age
, pkgs
, config
, ...
}: {
  config = {
    # TODO add a backup on a cronjob to b2.
    # Will finally have to get ahead of secret management: https://github.com/Mic92/sops-nix/?tab=readme-ov-file#deploy-example
    # https://nixos.wiki/wiki/Systemd/Timers

    environment.systemPackages = [
      # Just installing for psql and other such tools.
      pkgs.postgresql
      pkgs.tailscale
    ];

    age.secrets = {
      memento-deploy-key = {
        file = ../assets/secrets/memento-deploy-key.age;
      };
    };

    # RO SSH Key to allow cloning the memento repo.
    programs.ssh.extraConfig = ''
      Host github_memento_deploy
      	Hostname github.com
      	IdentityFile=${config.age.secrets.memento-deploy-key.path}
    '';

    services.tailscale.enable = true;

    networking.firewall = {
      # Allow tailscale to connect freely.
      trustedInterfaces = [ "tailscale0" ];

      allowedUDPPorts = [
        config.services.tailscale.port # tailscale
      ];
    };

    virtualisation.oci-containers.containers = {
      postgres = {
        # TODO pgvector
        image = "postgres:16.1";
        ports = [ "5432:5432" ];
        environment = {
          # pls no hack.
          POSTGRES_USER = "postgres";
          POSTGRES_PASSWORD = "password";
        };
        volumes = [
          "/home/chrisseto/pgdata:/var/lib/postgresql/data"
        ];
      };
    };
  };
}
