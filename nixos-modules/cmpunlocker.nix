# NixOS module for cmpunlocker (https://github.com/amoghmunikote/cmpunlocker).
#
# Declarative replacement for cmpunlocker's install.sh: patches the nvidia-open
# kernel modules, arms the early-boot PCIe Gen2 retrain, sets the cards up for
# VFIO passthrough without losing the unlock, and optionally enables IOMMU
# passthrough on the kernel command line.
#
# Usage:
#   imports = [ ./cmpunlocker.nix ];
#   hardware.cmpunlocker = {
#     enable = true;
#     iommu = "amd";  # or "intel"
#   };
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.cmpunlocker;
  src = cfg.src;
  kernelPackages = config.boot.kernelPackages;

  # driver/VERSION lists the nvidia-open releases the patches are written against.
  supportedVersions = lib.filter (v: builtins.match "[0-9]+\\.[0-9]+\\.[0-9]+" v != null) (
    lib.splitString "\n" (builtins.readFile "${src}/driver/VERSION")
  );

  # Must match PATCH_ORDER in driver/build.sh.
  patchOrder = [
    "sec2-postbl-plm-ss-cfg.patch"
    "booter-verify.patch"
    "late-pma.patch"
    "bar0-pramin-clamp.patch"
    "ce-scrub-workarounds.patch"
    "persistent-sw-state.patch"
    "pcie-gen2.patch"
    "pcie-gen2-probe-retrain.patch"
    "name-string.patch"
    "bar1-resize-unlock.patch"
    "cmp-sku-mask.patch"
    "ecc-enable.patch"
    "ecc-fbpa-static.patch"
    "ecc-reporting.patch"
  ];

  # The memory geometry is selected at runtime by PCI device ID
  # (sec2-postbl-plm-ss-cfg.patch carries both 8GB and 10GB values), so the
  # build-time CFG1/LMR rewrite in build.sh is a no-op and is not reproduced.
  patchedPackage = cfg.basePackage // {
    open = cfg.basePackage.open.overrideAttrs (old: {
      pname = "${old.pname or "nvidia-open"}-cmpunlocker";
      patches = (old.patches or [ ]) ++ map (p: "${src}/driver/patches/${p}") patchOrder;
    });
  };

  gen2Hammer = pkgs.runCommand "cmpunlocker-gen2-hammer" { } ''
    install -D -m 0755 ${src}/tools/hammer.sh $out/bin/gen2-hammer
    substituteInPlace $out/bin/gen2-hammer \
      --replace-fail 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
                     'PATH=${
                       lib.makeBinPath [
                         pkgs.pciutils
                         pkgs.coreutils
                         pkgs.gawk
                       ]
                     }'
    patchShebangs $out/bin/gen2-hammer
  '';

  cmpNoBusReset = kernelPackages.callPackage (
    { stdenv, kernel }:
    stdenv.mkDerivation {
      pname = "cmp-no-bus-reset";
      version = kernel.version;
      src = "${src}/driver/passthrough";

      nativeBuildInputs = kernel.moduleBuildDependencies;
      hardeningDisable = [
        "pic"
        "format"
      ];

      makeFlags = kernel.makeFlags ++ [
        "-C"
        "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
        "M=$(PWD)"
      ];
      buildFlags = [ "modules" ];

      installPhase = ''
        runHook preInstall
        install -D -m 0644 cmp_no_bus_reset.ko \
          $out/lib/modules/${kernel.modDirVersion}/extra/cmp_no_bus_reset.ko
        runHook postInstall
      '';
    }
  ) { };

  passthroughHelpers =
    pkgs.runCommand "cmpunlocker-passthrough-helpers"
      {
        nativeBuildInputs = [ (pkgs.python3.withPackages (p: [ p.pyyaml ])) ];
      }
      ''
        lib=$out/lib/cmpunlocker
        mkdir -p $lib

        # Same as tools/passthrough-setup.sh: flatten passthrough.gsp_boot_state
        # into the conf that gsp-restore reads from its own directory.
        python3 - ${src}/common/constants.yaml $lib/gsp-regs.conf <<'PY'
        import io, sys
        import yaml
        cpath, out = sys.argv[1:3]
        with io.open(cpath, encoding="utf-8") as f:
            c = yaml.safe_load(f) or {}
        regs = ((c.get("passthrough") or {}).get("gsp_boot_state") or {})
        if not regs:
            raise SystemExit("constants.yaml has no passthrough.gsp_boot_state")
        lines = ["# generated from common/constants.yaml by cmpunlocker.nix",
                 "# <addr> <value> <name>"]
        for name in sorted(regs):
            r = regs[name]
            lines.append("%s %s %s" % (r["addr"], r["value"], name))
        io.open(out, "w", encoding="utf-8", newline="\n").write("\n".join(lines) + "\n")
        PY

        install -m 0755 ${src}/tools/gsp-restore.py $lib/gsp-restore
        substituteInPlace $lib/gsp-restore \
          --replace-fail '#!/usr/bin/env python3' '#!${pkgs.python3}/bin/python3'

        install -m 0755 ${src}/tools/passthrough-arm.sh $lib/passthrough-arm
        substituteInPlace $lib/passthrough-arm \
          --replace-fail '#!/bin/bash' '#!${pkgs.bash}/bin/bash
        export PATH=${
          lib.makeBinPath [
            pkgs.pciutils
            pkgs.kmod
            pkgs.gawk
            pkgs.gnugrep
            pkgs.coreutils
            config.hardware.nvidia.package.bin
          ]
        }:$PATH'
      '';
in
{
  options.hardware.cmpunlocker = {
    enable = lib.mkEnableOption "cmpunlocker for the NVIDIA CMP 170HX";

    src = lib.mkOption {
      type = lib.types.path;
      default = pkgs.fetchFromGitHub {
        owner = "amoghmunikote";
        repo = "cmpunlocker";
        rev = "2c7e2ecd7944e791fec040d2680036beb4a9327b";
        hash = "sha256-stQ2JUzdE5fa90KOerhFXs9uzfxYayqyaUm9UowXG9w=";
      };
      defaultText = lib.literalMD "cmpunlocker at commit `2c7e2ec` fetched from GitHub";
      description = "cmpunlocker source tree providing the patches and helper scripts.";
    };

    basePackage = lib.mkOption {
      type = lib.types.package;
      default = kernelPackages.nvidiaPackages.latest;
      defaultText = lib.literalExpression "config.boot.kernelPackages.nvidiaPackages.latest";
      example = lib.literalExpression ''
        config.boot.kernelPackages.nvidiaPackages.mkDriver {
          version = "615.78.08";
          sha256_64bit = lib.fakeHash;
          openSha256 = lib.fakeHash;
          settingsSha256 = lib.fakeHash;
          persistencedSha256 = lib.fakeHash;
        }
      '';
      description = ''
        Stock NVIDIA driver whose open kernel modules get patched. Its version
        must be one listed in cmpunlocker's driver/VERSION; use
        `nvidiaPackages.mkDriver` if nixpkgs does not ship a supported one.
      '';
    };

    gen2Service.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Run the early-boot PCIe Gen2 retrain loop (cmpunlocker-gen2.service).
        Boot with `systemd.mask=cmpunlocker-gen2.service` to skip it for recovery.
      '';
    };

    passthrough.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Make the unlock survive handing a card to vfio-pci: block bus resets with
        cmp_no_bus_reset.ko and restore GSP boot registers on vfio-pci bind.
      '';
    };

    iommu = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "intel"
          "amd"
        ]
      );
      default = null;
      description = ''
        Add `<vendor>_iommu=on iommu=pt` to the kernel command line.
        `null` leaves the command line alone. IOMMU must also be enabled in firmware.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = lib.elem cfg.basePackage.version supportedVersions;
            message = "cmpunlocker: NVIDIA driver ${cfg.basePackage.version} is unsupported; need one of: ${lib.concatStringsSep ", " supportedVersions}";
          }
          {
            assertion = cfg.basePackage.open or null != null;
            message = "cmpunlocker: hardware.cmpunlocker.basePackage has no open kernel modules";
          }
        ];

        services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];
        hardware.nvidia.open = true;
        hardware.nvidia.package = patchedPackage;

        # Conflicts with any other NVreg_RegistryDwords set for the nvidia module.
        boot.extraModprobeConfig = ''
          options nvidia NVreg_RegistryDwords="RmForceEnableGen2=1;RMPcieLinkSpeed=0x1"
        '';

        environment.systemPackages = [ pkgs.pciutils ];
      }

      (lib.mkIf cfg.gen2Service.enable {
        systemd.services.cmpunlocker-gen2 = {
          description = "CMP 170HX early-boot PCIe Gen2 retrain";
          unitConfig.DefaultDependencies = false;
          after = [ "sysinit.target" ];
          before = [
            "basic.target"
            "multi-user.target"
            "graphical.target"
          ];
          wantedBy = [ "sysinit.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${gen2Hammer}/bin/gen2-hammer";
            TimeoutStartSec = 45;
            RemainAfterExit = false;
          };
        };
      })

      (lib.mkIf cfg.passthrough.enable {
        boot.extraModulePackages = [ cmpNoBusReset ];

        boot.extraModprobeConfig = ''
          options vfio-pci disable_idle_d3=1
        '';

        systemd.services.cmpunlocker-passthrough = {
          description = "cmpunlocker: arm CMP 170HX cards for VM passthrough";
          after = [ "nvidia-persistenced.service" ];
          wants = [ "nvidia-persistenced.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${passthroughHelpers}/lib/cmpunlocker/passthrough-arm";
          };
        };

        # When a CMP 170HX is handed to vfio-pci, put its GSP boot-time registers
        # back so a guest can still boot GSP. The card is never reset, so the
        # unlock survives.
        services.udev.extraRules = ''
          ACTION=="bind", SUBSYSTEM=="pci", DRIVER=="vfio-pci", ATTR{vendor}=="0x10de", ATTR{device}=="0x20c2", RUN+="${passthroughHelpers}/lib/cmpunlocker/gsp-restore %k"
          ACTION=="bind", SUBSYSTEM=="pci", DRIVER=="vfio-pci", ATTR{vendor}=="0x10de", ATTR{device}=="0x2082", RUN+="${passthroughHelpers}/lib/cmpunlocker/gsp-restore %k"
        '';
      })

      (lib.mkIf (cfg.iommu != null) {
        boot.kernelParams = [
          "${cfg.iommu}_iommu=on"
          "iommu=pt"
        ];
      })
    ]
  );
}
