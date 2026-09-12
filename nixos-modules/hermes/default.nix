{ config, lib, pkgs, inputs, ... }:
{
  options.services.hermes = {
    enable = lib.mkEnableOption "Hermes agent";
    persistencePath = lib.mkOption {
      type = lib.types.str;
      description = "Host directory holding the persistent state (bind-mounted into the containers).";
    };
  };

  config = lib.mkIf config.services.hermes.enable {
    # TODO assertions on path.

    virtualisation.quadlet = {
      enable = true;

      images = {
        # Ensure the image is pulled into our cache.
        hermes-agent = {
          imageConfig.Image = "docker.io/nousresearch/hermes-agent";
          imageConfig.ImageTag = "docker.io/nousresearch/hermes-agent:v2026.8.19";
        };

        signal-cli = {
          imageConfig.Image = "registry.gitlab.com/packaging/signal-cli/signal-cli-native";
          imageConfig.ImageTag = "registry.gitlab.com/packaging/signal-cli/signal-cli-native:v0-14-7-1";
        };
      };

      builds = {
        # Build our custom image.
        hermes-agent = {
          buildConfig =
            let
              ctx = pkgs.runCommand "build-ctx" { } ''
                mkdir -p $out
                cp ${./dashboard-insecure.patch} $out/dashboard-insecure.patch
                cp ${./hermes-agent.Containerfile} $out/Containerfile
              '';
            in
            {
              ImageTag = "localhost/hermes-agent:latest";
              SetWorkingDirectory = "${ctx}";
              File = "${ctx}/Containerfile";
            };
        };
      };

      pods = {
        hermes = {
          podConfig.PodName = "hermes";
        };
      };

      networks = {
        hermes = {
          networkConfig.NetworkName = "hermes";
        };
      };

      containers = {
        hermes-agent = {
          containerConfig = {

            Pod = "hermes.pod";
            Network = "hermes.network";
            Image = "hermes-agent.build";
            ContainerName = "hermes-gateway";
            Exec = "gateway run";
            Environment = {
              HERMES_DASHBOARD = "1";
              HERMES_DASHBOARD_INSECURE = "1";
              SIGNAL_HTTP_URL = "http://signal-api:8080";
            };
            PublishPort = [ "8642:8642" "9119:9119" ];
            Volume = "/external/hermes:/opt/data";
          };
        };

        signal-cli = {
          # For linking follow https://github.com/AsamK/signal-cli/wiki/Linking-other-devices-%28Provisioning%29
          containerConfig = {
            Pod = "hermes.pod";
            Network = "hermes.network";
            Image = "signal-cli.image";
            ContainerName = "signal-api";
            Exec = "daemon --http 0.0.0.0:8080";
            Volume = "/external/signal-cli:/home/.local/share/signal-cli";
            HealthStartPeriod = "5s";
          };
        };
      };
    };
  };
}
