{ pkgs
, lib
, config
, ...
}: {
  config = {
    # Create a shared group for all NAS services
    users.groups.nasdaemons = { gid = 995; };
    users.users = {
      jellyfin = { isSystemUser = true; uid = 994; group = "nasdaemons"; };
      radarr = { isSystemUser = true; uid = 275; group = "nasdaemons"; };
      sabnzbd = { isSystemUser = true; uid = 38; group = "nasdaemons"; };
      sonarr = { isSystemUser = true; uid = 274; group = "nasdaemons"; };
    };

    systemd.mounts = [
      {
        description = "External Drive Pool";
        what = "/dev/disk/by-uuid/9f2b8872-d9c0-4762-a09a-97e82d2c8d48";
        where = "/external";
        options = "noatime";
        type = "btrfs";
      }
      {
        description = "Bazarr configuration";
        what = "/dev/disk/by-uuid/9f2b8872-d9c0-4762-a09a-97e82d2c8d48";
        where = "/var/lib/bazarr";
        options = "subvol=configs/bazarr";
        type = "btrfs";
      }
      {
        description = "Jellyfin configuration";
        what = "/dev/disk/by-uuid/9f2b8872-d9c0-4762-a09a-97e82d2c8d48";
        where = "/var/lib/jellyfin";
        options = "subvol=configs/jellyfin";
        type = "btrfs";
      }
      {
        description = "Radarr configuration";
        what = "/dev/disk/by-uuid/9f2b8872-d9c0-4762-a09a-97e82d2c8d48";
        where = "/var/lib/radarr";
        options = "subvol=configs/radarr";
        type = "btrfs";
      }
      {
        description = "Sabnzbd configuration";
        what = "/dev/disk/by-uuid/9f2b8872-d9c0-4762-a09a-97e82d2c8d48";
        where = "/var/lib/sabnzbd";
        options = "subvol=configs/sabnzbd";
        type = "btrfs";
      }
      {
        description = "Sonarr configuration";
        what = "/dev/disk/by-uuid/9f2b8872-d9c0-4762-a09a-97e82d2c8d48";
        where = "/var/lib/sonarr";
        options = "subvol=configs/sonarr";
        type = "btrfs";
      }
    ];

    # TODO It might be possible / better to do this with systemd units if
    # possible?
    systemd.tmpfiles.rules = [
      "d /external/downloads/complete 0775 root nasdaemons - -"
      "d /external/downloads/incomplete 0775 root nasdaemons - -"
      "d /external/media/movies 0775 root nasdaemons - -"
      "d /external/media/tv-shows 0775 root nasdaemons - -"
      "d /var/lib/radarr 0770 radarr nasdaemons - -"
      "d /var/lib/sabnzbd/ 0770 sabnzbd nasdaemons - -"
      "d /var/lib/sonarr 0770 sonarr nasdaemons - -"
    ];

    # Make podman services require any mounts they use.
    systemd.services = {
      podman-radarr = {
        after = [
          "external.mount"
          "var-lib-radarr.mount"
          "systemd-tmpfiles-setup.service"
        ];
        requires = [
          "external.mount"
          "var-lib-radarr.mount"
          "systemd-tmpfiles-setup.service"
        ];
      };
      podman-sonarr = {
        after = [
          "external.mount"
          "var-lib-sonarr.mount"
          "systemd-tmpfiles-setup.service"
        ];
        requires = [
          "external.mount"
          "var-lib-sonarr.mount"
          "systemd-tmpfiles-setup.service"
        ];
      };
      podman-sabnzbd = {
        after = [
          "external.mount"
          "var-lib-sabnzbd.mount"
          "systemd-tmpfiles-setup.service"
        ];
        requires = [
          "external.mount"
          "var-lib-sabnzbd.mount"
          "systemd-tmpfiles-setup.service"
        ];
      };
      podman-jellyfin = {
        after = [
          "external.mount"
          "var-lib-jellyfin.mount"
          "systemd-tmpfiles-setup.service"
        ];
        requires = [
          "external.mount"
          "var-lib-jellyfin.mount"
          "systemd-tmpfiles-setup.service"
        ];
      };
    };

    services.tailscale.enable = true;

    environment.systemPackages = [
      pkgs.tailscale
    ];

    networking.firewall = {
      # Allow tailscale to connect freely.
      trustedInterfaces = [ "tailscale0" ];

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
        config.services.tailscale.port # tailscale
      ];
    };

    services.traefik = {
      enable = true;

      staticConfigOptions = {
        entryPoints.http.address = ":80";
      };

      dynamicConfigOptions = {
        http.services.bazarr.loadBalancer.servers = [
          { url = "http://localhost:6767"; }
        ];

        http.services.radarr.loadBalancer.servers = [
          { url = "http://localhost:7878"; }
        ];

        http.services.sabnzbd.loadBalancer.servers = [
          { url = "http://localhost:8080"; }
        ];

        http.services.sonarr.loadBalancer.servers = [
          { url = "http://localhost:8989"; }
        ];

        http.services.jellyfin.loadBalancer.servers = [
          { url = "http://localhost:8096"; }
        ];

        http.routers.to-jellyfin = {
          rule = "Host(`jellyfin.home.seto.xyz`)";
          service = "jellyfin";
        };

        http.routers.to-bazarr = {
          rule = "Host(`bazarr.home.seto.xyz`) || PathPrefix(`/bazarr`)";
          service = "bazarr";
        };

        http.routers.to-radarr = {
          rule = "Host(`radarr.home.seto.xyz`) || PathPrefix(`/radarr`)";
          service = "radarr";
        };

        http.routers.to-sabnzbd = {
          rule = "Host(`sabnzbd.home.seto.xyz`) || PathPrefix(`/sabnzbd`)";
          service = "sabnzbd";
        };

        http.routers.to-sonarr = {
          rule = "Host(`sonarr.home.seto.xyz`) || PathPrefix(`/sonarr`)";
          service = "sonarr";
        };
      };
    };

    virtualisation.oci-containers.containers = {
      # TODO ?
      # Web service serving open whisper (AI subtitle generator).
      # whisper = {
      #   image = "onerahmet/openai-whisper-asr-webservice:latest";
      #   ports = [ "127.0.0.1:9000:9000" ];
      #   environment = {
      #     ASR_MODEL = "base.en";
      #   };
      # };

      sonarr = {
        autoStart = true;
        image = "ghcr.io/hotio/sonarr:release-4.0.14.2939";
        ports = [
          "8989:8989"
        ];

        volumes = [
          "/var/lib/sonarr/.config/NzbDrone:/config"
          "/external/media/tv-shows:/external/media/tv-shows"
          "/external/downloads/complete:/external/downloads/complete"
        ];

        environment = {
          TZ = "America/New_York";
          PUID = toString config.users.users.sonarr.uid;
          PGID = toString config.users.groups.nasdaemons.gid;
        };
      };

      radarr = {
        autoStart = true;
        image = "ghcr.io/hotio/radarr:release-5.21.1.9799";
        ports = [
          "7878:7878"
        ];

        volumes = [
          "/var/lib/radarr/.config/Radarr:/config"
          "/external/media/movies:/external/media/movies"
          "/external/downloads/complete:/external/downloads/complete"
        ];

        environment = {
          TZ = "America/New_York";
          PUID = toString config.users.users.radarr.uid;
          PGID = toString config.users.groups.nasdaemons.gid;
        };
      };

      jellyfin = {
        autoStart = true;
        image = "ghcr.io/hotio/jellyfin:release-10.10.7";
        ports = [
          "8096:8096"
          "1900:1900/udp"
          "7359:7359/udp"
        ];

        volumes = [
          "/var/lib/jellyfin/:/config"
          "/external/media:/external/media"
        ];

        environment = {
          TZ = "America/New_York";
          PUID = toString config.users.users.jellyfin.uid;
          PGID = toString config.users.groups.nasdaemons.gid;
        };
      };

      sabnzbd = {
        autoStart = true;
        image = "docker.io/linuxserver/sabnzbd:3.5.3";
        ports = [
          "8080:8080"
        ];

        volumes = [
          "/var/lib/sabnzbd:/config"
          "/external/downloads:/external/downloads"
        ];

        environment = {
          TZ = "America/New_York";
          PUID = toString config.users.users.sabnzbd.uid;
          PGID = toString config.users.groups.nasdaemons.gid;
        };
      };
    };

    # TODO
    # services.bazarr = {
    #   enable = true;
    #   group = "nasdaemons";
    # };
  };
}
