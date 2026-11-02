# Ataraxy Labs' `sem` semantic-diff CLI, as used by plannotator.
# Pinned to the SEM_VERSION plannotator's install.sh ships with; sources.json
# is written by ../plannotator/update.sh.
{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, darwin
, openssl
, zlib
}:
let
  sources = lib.importJSON ./sources.json;
  inherit (sources) version archives;
  inherit (stdenv.hostPlatform) system;
in
stdenv.mkDerivation {
  pname = "sem";
  inherit version;

  src = fetchurl {
    url = "https://github.com/Ataraxy-Labs/sem/releases/download/v${version}/${archives.${system}.asset}";
    inherit (archives.${system}) hash;
  };
  sourceRoot = ".";

  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ]
    ++ lib.optionals stdenv.isDarwin [ darwin.sigtool ];
  buildInputs = [ openssl zlib ]
    ++ lib.optionals stdenv.isLinux [ stdenv.cc.cc.lib ];

  installPhase = ''
    install -Dm755 "$(find . -type f -name sem -print -quit)" $out/bin/sem
  '' + lib.optionalString stdenv.isDarwin ''
    # The darwin build links Homebrew's openssl@3; point it at nixpkgs'.
    for lib in libssl.3.dylib libcrypto.3.dylib; do
      install_name_tool -change /opt/homebrew/opt/openssl@3/lib/$lib \
        ${lib.getLib openssl}/lib/$lib $out/bin/sem
    done
    codesign -f -s - $out/bin/sem
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/sem --version | grep -q '^sem ${version}'
  '';

  meta = {
    description = "Semantic diff CLI";
    homepage = "https://github.com/Ataraxy-Labs/sem";
    # Upstream publishes no darwin-x64 build.
    platforms = builtins.attrNames archives;
    mainProgram = "sem";
  };
}
