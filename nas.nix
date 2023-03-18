{
  pkgs,
  lib,
  ...
}: {
  config = {
    # Create a shared group for all NAS services
    users.groups.nasdaemons = {};

    # TODO: systemd has this build into the serviceConfig. See Jellyfin's
    # config.
    systemd.tmpfiles.rules = [
      "d /external/data 0755 root nasdaemons - -"
      "d /external/data/downloads/complete 0775 sabnzbd nasdaemons - -"
      "d /external/data/downloads/incomplete 0775 sabnzbd nasdaemons - -"
      "d /external/data/movies 0775 root nasdaemons - -"
      "d /external/data/shows 0775 root nasdaemons - -"
      "d /var/lib/prowlarr 0700 prowlarr nasdaemons - -"
    ];

    networking.firewall = {
      allowedTCPPorts = [
        80 # traefik
        8096 # jellyfin

        # Only required when bootstrapping the system. Once up and running,
        # configure the subpaths for each service and disable ingress. sabnzbd
        # automatically serves itself under /sabnzbd, so no configuration is
        # needed.
        # 8989 # sonarr
        # 7878 # radarr
        # 9696 # prowlarr
        # 8080 # sabnzbd
      ];
      allowedUDPPorts = [
        1900 # jelyyfin - service discovery
        7359 # jellyfin - service discovery
      ];
    };

    services.traefik = {
      enable = true;

      staticConfigOptions = {
        entryPoints.http.address = ":80";
      };

      dynamicConfigOptions = {
        http.services.sonarr.loadBalancer.servers = [
          {url = "http://localhost:8989";}
        ];

        http.services.radarr.loadBalancer.servers = [
          {url = "http://localhost:7878";}
        ];

        http.services.prowlarr.loadBalancer.servers = [
          {url = "http://localhost:9696";}
        ];

        http.services.sabnzbd.loadBalancer.servers = [
          {url = "http://localhost:8080";}
        ];

        http.routers.to-sabnzbd = {
          rule = "PathPrefix(`/sabnzbd`)";
          service = "sabnzbd";
        };

        http.routers.to-sonarr = {
          rule = "PathPrefix(`/sonarr`) || HeadersRegexp(`Referer`, `https?://[^/]+/sonarr.*`)";
          service = "sonarr";
        };

        http.routers.to-radarr = {
          rule = "PathPrefix(`/radarr`)";
          service = "radarr";
        };

        http.routers.to-prowlarr = {
          rule = "PathPrefix(`/prowlarr`)";
          service = "prowlarr";
        };
      };
    };

    services.jellyfin = {
      enable = true;
      group = "nasdaemons";
    };

    services.sabnzbd = {
      enable = true;
      group = "nasdaemons";
    };

    services.sonarr = {
      enable = true;
      group = "nasdaemons";
    };

    services.radarr = {
      enable = true;
      group = "nasdaemons";
    };

    # Prowlarr's service definition is a bit broken in the upstream.
    # TODO: Pull this into an overlay.
    # TODO: Copy the same configuration for all nas daemon services.
    # TODO: Mount /var/lib as a btrfs subvolume.
    # services.prowlarr = {
    #   enable = true;
    #   group = "nasdaemons";
    # };

    users.users = {
      prowlarr = {
        isSystemUser = true;
        group = "nasdaemons";
        home = "/var/lib/prowlarr";
      };
    };

    systemd.services.prowlarr = {
      description = "Prowlarr";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        User = "prowlarr";
        Group = "nasdaemons";
        ExecStart = "${pkgs.prowlarr}/bin/Prowlarr -nobrowser -data=/var/lib/prowlarr";
        Restart = "on-failure";
      };
    };
  };
}
