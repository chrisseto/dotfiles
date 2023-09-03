self: super: {
  # Patch janet up to the latest version.
  janet = super.janet.overrideAttrs (old: rec {
    version = "1.30.0";

    src = super.fetchFromGitHub {
      owner = "janet-lang";
      repo = "janet";
      rev = "v${version}";
      sha256 = "sha256-tkXEi8m7eroie/yP1kW0V6Ld5SCLA0/KmtHHI0fIsRI=";
    };
  });

  # Fix jpm. :headerpath needs to point to janet.h
  # TODO: add support for janet.withPackages so I don't have to manage a local
  # install of spork.
  jpm = super.jpm.overrideAttrs (old: let
    platformFiles = {
      aarch64-darwin = "macos_config.janet";
      aarch64-linux = "linux_config.janet";
      x86_64-darwin = "macos_config.janet";
      x86_64-linux = "linux_config.janet";
    };

    platformFile = platformFiles.${super.stdenv.hostPlatform.system};
  in {
    # `auto-shebangs true` gives us a shebang line that points to janet inside the
    # jpm bin folder
    postPatch = ''
      substituteInPlace configs/${platformFile} \
        --replace 'auto-shebang true' 'auto-shebang false' \
        --replace ':headerpath (string prefix' ':headerpath (string "${super.pkgs.janet}"' \
        --replace /usr/local $out
    '';
  });
}
