{ stdenv ? (import <nixpkgs> { }).stdenv
, fetchzip ? (import <nixpkgs> { }).fetchzip
,
}:
stdenv.mkDerivation {
  pname = "hammerspoon";
  version = "0.9.96";

  src = fetchzip {
    url = "https://github.com/Hammerspoon/hammerspoon/releases/download/0.9.96/Hammerspoon-0.9.96.zip";
    sha256 = "sha256-3euDPI0qJD3Nj7mUAUKDab/ZFQTcRVU68oNmQe+DxKQ=";
  };

  installPhase = ''
    mkdir -p $out/Applications/Hammerspoon.app
    mv ./* $out/Applications/Hammerspoon.app
    chmod +x "$out/Applications/Hammerspoon.app/Contents/MacOS/Hammerspoon"
  '';

  meta = {
    description = "Staggeringly powerful macOS desktop automation with Lua";
    # license = stdenv.lib.licenses.mit;
    homepage = "https://www.hammerspoon.org";
    # platforms = stdenv.lib.platforms.darwin;
  };
}
