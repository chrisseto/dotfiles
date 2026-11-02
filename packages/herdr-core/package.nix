# Prebuilt herdr-core (`hc`), as https://releases.herdr.dev/core/install.sh
# installs it. Versions and hashes live in sources.json; bump with
# ./update.sh [version]. herdr-core recognizes a /nix/store install as
# managed, so `hc update` and the Herdr app defer to Nix.
{ lib
, stdenv
, stdenvNoCC
, fetchurl
}:
let
  sources = lib.importJSON ./sources.json;
  inherit (sources) version targets;
  inherit (stdenv.hostPlatform) system;
in
stdenvNoCC.mkDerivation {
  pname = "herdr-core";
  inherit version;

  src = fetchurl {
    inherit (targets.${system}) url hash;
  };
  sourceRoot = ".";

  # Static on Linux, system frameworks only on macOS: nothing to patch.
  dontStrip = true;

  installPhase = ''
    install -Dm755 herdr-core $out/bin/herdr-core
    ln -s herdr-core $out/bin/hc
    install -Dm644 -t $out/share/doc/herdr-core LICENSE THIRD-PARTY-NOTICES
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/hc --version | grep -qx 'hc ${version}'
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Terminal runtime for coding agents (hc)";
    homepage = "https://herdr.dev";
    platforms = builtins.attrNames targets;
    mainProgram = "hc";
  };
}
