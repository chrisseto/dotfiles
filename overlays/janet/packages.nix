{ janet
, jpm
, stdenv
, fetchFromGitHub
,
} @ defs:
let
  buildJanetPackage =
    { src
    , jpm ? defs.jpm
    , janet ? defs.janet
    , nativeBuildInputs ? [ ]
    , ...
    } @ attrs:
    stdenv.mkDerivation (attrs
      // {
      inherit src;

      dontConfigure = true;

      nativeBuildInputs = [ janet jpm ] ++ nativeBuildInputs;

      # TODO there's probably just a build command or something I can set
      # TODO deps
      # TODO run tests (?)
      # TODO verify proper environments and what not are being used
      buildPhase = ''
        runHook preBuild

        jpm build --offline --local

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        JANET_TREE=$out jpm install --offline

        runHook postInstall
      '';
    });
in
rec {
  # TODO add a package with deps.
  spork = buildJanetPackage {
    name = "spork";
    version = "1.0.0";

    src = fetchFromGitHub {
      owner = "janet-lang";
      repo = "spork";
      rev = "d644da0fd05612a2d5a3c97277bf7b9bb96dcf6b";
      hash = "sha256-VSaYuFFnDv7c8IhTzlH8hk/7BFbFdbPI4f83pw8+98U=";
    };
  };

  posix-spawn = buildJanetPackage {
    name = "posix-spawn";
    version = "0.0.2";
    src = fetchFromGitHub {
      owner = "andrewchambers";
      repo = "janet-posix-spawn";
      rev = "d73057161a8d10f27b20e69f0c1e2ceb3e145f97";
      hash = "sha256-kiEPQKiAZ+zPY7cBEhTYrdIVVu9353Mpeq3YbB27u8w=";
    };
  };

  sh = buildJanetPackage {
    propagatedBuildInputs = [ posix-spawn ];

    name = "sh";
    version = "0.0.2";
    src = fetchFromGitHub {
      owner = "andrewchambers";
      repo = "janet-sh";
      rev = "221bcc869bf998186d3c56a388c8313060bfd730";
      hash = "sha256-pqpEs/qfHe/e2ywSuqzWZhfw/YHZNkTsKHZHoaoVTc4=";
    };
  };
}
