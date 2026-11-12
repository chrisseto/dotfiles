# Prebuilt plannotator release binary (https://plannotator.ai/install.sh).
# Versions and hashes live in sources.json; bump with ./update.sh [version].
# The semantic-diff sidecar it uses comes from the `sem` flake input.
{ lib
, stdenv
, stdenvNoCC
, fetchurl
, autoPatchelfHook
}:
let
  sources = lib.importJSON ./sources.json;
  inherit (sources) version binaries;
  inherit (stdenv.hostPlatform) system;
in
stdenvNoCC.mkDerivation {
  pname = "plannotator";
  inherit version;

  src = fetchurl {
    url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/${binaries.${system}.asset}";
    inherit (binaries.${system}) hash;
  };

  dontUnpack = true;
  # A Bun-compiled single-file executable: stripping or patching it would
  # corrupt the embedded payload.
  dontStrip = true;
  dontPatchELF = true;
  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.isLinux [ stdenv.cc.cc.lib ];

  installPhase = ''
    install -Dm755 $src $out/bin/plannotator
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/plannotator --version | grep -qx 'plannotator ${version}'
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Visual plan and code review for coding agents";
    homepage = "https://plannotator.ai";
    platforms = builtins.attrNames binaries;
    mainProgram = "plannotator";
  };
}
