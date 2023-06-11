{
  pkgs,
  lib,
  ...
}: {
  config = {
    # Create a shared group for all NAS services
    users.groups.nasdaemons = {};

    systemd.mounts = [
      {
        description = "External Drive Pool";
        what = "/dev/disk/by-uuid/9f2b8872-d9c0-4762-a09a-97e82d2c8d48";
        where = "/external";
        options = "noatime";
        type = "btrfs";
        wantedBy = ["sabnzbd.service" "radarr.service" "sonarr.service"];
        partOf = ["sabnzbd.service" "radarr.service" "sonarr.service"];
      }
      {
        description = "Bazarr configuration";
        what = "/dev/disk/by-uuid/9f2b8872-d9c0-4762-a09a-97e82d2c8d48";
        where = "/var/lib/bazarr";
        options = "subvol=configs/bazarr";
        type = "btrfs";
        partOf = ["bazarr.service"];
        wantedBy = ["bazarr.service"];
      }
      {
        description = "Jellyfin configuration";
        what = "/dev/disk/by-uuid/9f2b8872-d9c0-4762-a09a-97e82d2c8d48";
        where = "/var/lib/jellyfin";
        options = "subvol=configs/jellyfin";
        type = "btrfs";
        partOf = ["jellyfin.service"];
        wantedBy = ["jellyfin.service"];
      }
      {
        description = "Radarr configuration";
        what = "/dev/disk/by-uuid/9f2b8872-d9c0-4762-a09a-97e82d2c8d48";
        where = "/var/lib/radarr";
        options = "subvol=configs/radarr";
        type = "btrfs";
        partOf = ["radarr.service"];
        wantedBy = ["radarr.service"];
      }
      {
        description = "Sabnzbd configuration";
        what = "/dev/disk/by-uuid/9f2b8872-d9c0-4762-a09a-97e82d2c8d48";
        where = "/var/lib/sabnzbd";
        options = "subvol=configs/sabnzbd";
        type = "btrfs";
        wantedBy = ["sabnzbd.service"];
        partOf = ["sabnzbd.service"];
      }
      {
        description = "Sonarr configuration";
        what = "/dev/disk/by-uuid/9f2b8872-d9c0-4762-a09a-97e82d2c8d48";
        where = "/var/lib/sonarr";
        options = "subvol=configs/sonarr";
        type = "btrfs";
        partOf = ["sonarr.service"];
        wantedBy = ["sonarr.service"];
      }
    ];

    # The override here was taken from jellyfin's config. It causes systemd to
    # automatically chown these directories. Not sure how effective this actually is.

    systemd.services.radarr.serviceConfig.StateDirectory = "radarr";
    systemd.services.radarr.serviceConfig.StateDirectoryMode = "0700";

    systemd.services.sabnzbd.serviceConfig.StateDirectory = "sabnzbd";
    systemd.services.sabnzbd.serviceConfig.StateDirectoryMode = "0700";

    systemd.services.sonarr.serviceConfig.StateDirectory = "sonarr";
    systemd.services.sonarr.serviceConfig.StateDirectoryMode = "0700";

    systemd.services.bazarr.serviceConfig.StateDirectory = "bazarr";
    systemd.services.bazarr.serviceConfig.StateDirectoryMode = "0700";

    # TODO: systemd has this build into the serviceConfig. See Jellyfin's
    # config.
    systemd.tmpfiles.rules = [
      "d /external/media/movies 0775 root nasdaemons - -"
      "d /external/media/tv-shows 0775 root nasdaemons - -"
      "d /external/downloads/complete 0775 root nasdaemons - -"
      "d /external/downloads/incomplete 0775 root nasdaemons - -"
      #   "d /external/data/downloads/complete 0775 sabnzbd nasdaemons - -"
      #   "d /external/data/downloads/incomplete 0775 sabnzbd nasdaemons - -"
      #   "d /external/data/movies 0775 root nasdaemons - -"
      #   "d /external/data/shows 0775 root nasdaemons - -"
      #   "d /var/lib/prowlarr 0700 prowlarr nasdaemons - -"
      #   "d /var/lib/radarr 0700 radarr nasdaemons - -"
      #   "d /var/lib/sonarr 0700 sonarr nasdaemons - -"
    ];

    networking.firewall = {
      allowedTCPPorts = [
        80 # traefik
        8096 # jellyfin

        # Only required when bootstrapping the system. Once up and running,
        # configure the subpaths for each service and disable ingress. sabnzbd
        # automatically serves itself under /sabnzbd, so no configuration is
        # needed.
        # 6767 # bazarr
        # 8989 # sonarr
        # 7878 # radarr
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
        http.services.bazarr.loadBalancer.servers = [
          {url = "http://localhost:6767";}
        ];

        http.services.radarr.loadBalancer.servers = [
          {url = "http://localhost:7878";}
        ];

        http.services.sabnzbd.loadBalancer.servers = [
          {url = "http://localhost:8080";}
        ];

        http.services.sonarr.loadBalancer.servers = [
          {url = "http://localhost:8989";}
        ];

        http.routers.to-bazarr = {
          rule = "PathPrefix(`/bazarr`)";
          service = "bazarr";
        };

        http.routers.to-radarr = {
          rule = "PathPrefix(`/radarr`)";
          service = "radarr";
        };

        http.routers.to-sabnzbd = {
          rule = "PathPrefix(`/sabnzbd`)";
          service = "sabnzbd";
        };

        http.routers.to-sonarr = {
          rule = "PathPrefix(`/sonarr`)";
          service = "sonarr";
        };
      };
    };

    # Web service serving open whisper (AI subtitle generator).
    virtualisation.oci-containers.containers = {
      whisper = {
        image = "onerahmet/openai-whisper-asr-webservice:latest";
        ports = ["127.0.0.1:9000:9000"];
        environment = {
          ASR_MODEL = "base.en";
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

    services.bazarr = {
      enable = true;
      group = "nasdaemons";
    };

    users.users = {
      prowlarr = {
        isSystemUser = true;
        group = "nasdaemons";
        home = "/var/lib/prowlarr";
      };
    };
  };
}
