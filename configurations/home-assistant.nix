{ ... }: {
  systemd.mounts = [
    {
      description = "Home-Assistant configuration";
      what = "/dev/disk/by-uuid/9f2b8872-d9c0-4762-a09a-97e82d2c8d48";
      where = "/var/lib/home-assistant";
      options = "subvol=configs/home-assistant";
      options = "noatime";
      type = "btrfs";
      wantedBy = [ "podman-homeassistant.service" ];
      partOf = [ "podman-homeassistant.service" ];
    }
  ];

  virtualisation.oci-containers.containers = {
    homeassistant = {
      volumes = [ "/var/lib/home-assistant:/config" ];

      # https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
      environment.TZ = "America/New_York";

      # https://github.com/home-assistant/core/pkgs/container/home-assistant
      image = "ghcr.io/home-assistant/home-assistant:2024.3";

      extraOptions = [ "--network=host" ];
    };
  };
}
