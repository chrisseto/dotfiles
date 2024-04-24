{ config, ... }: {

  age.secrets = {
    traefik-env-file = {
      # A agenix secret for an env file containing:
      # CLOUDFLARE_DNS_API_TOKEN=...
      # As described by https://go-acme.github.io/lego/dns/cloudflare/
      file = ./seto-world-cloudflare-token.age;
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 443 ];
  };

  services.traefik = {
    enable = true;

    # Specify the agenix secret so traefik "sees" it.
    environmentFiles = [ config.age.secrets.traefik-env-file.path ];

    staticConfigOptions = {
      # Only listen for HTTPS traffic.
      entryPoints.https.address = ":443";

      certificatesResolvers.cloudflare-le.acme = {
        # Explicitly specify the full path to the default traefik config
        # directory.
        # https://github.com/NixOS/nixpkgs/blob/b471f1b0c8c315cf227533f0a0752952cc91ee4b/nixos/modules/services/web-servers/traefik.nix#L111
        storage = "/var/lib/traefik/acme.json";

        dnsChallenge = {
          provider = "cloudflare";
        };
      };
    };

    dynamicConfigOptions = {
      http.services.silverbullet.loadBalancer.servers = [
        {
          url = "http://localhost:3000";
        }
      ];

      http.routers.to-silverbullet = {
        rule = "Host(`sb.home.seto.xyz`)";
        service = "silverbullet";
      };

      http.routers.silverbullet = {
        rule = "Host(`notes.seto.world`)";
        service = "silverbullet";
        tls = {
          certResolver = "cloudflare-le";
        };
      };
    };
  };

  virtualisation.oci-containers.containers = {
    silverbullet = {
      volumes = [ "/var/lib/silverbullet:/space" ];

      image = "zefhemel/silverbullet:0.7.6";

      ports = [ "3000:3000" ];
    };
  };
}
