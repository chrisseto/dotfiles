{pkgs ? import <nixpkgs> {}}:
pkgs.stdenv.mkDerivation {
  name = "cockroach";
  version = "22.2.5";

  src = pkgs.fetchzip {
    url = "https://binaries.cockroachdb.com/cockroach-v22.2.5.darwin-11.0-arm64.tgz";
    sha256 = "sha256-cbOaReUIKRexNyONVc6Hxi7Lm6p1os4jM/IsI7Py0/Y=";
  };
  phases = ["installPhase" "patchPhase"];
  installPhase = ''
    mkdir -p $out/bin
    cp $src/cockroach $out/bin/cockroach
    chmod +x $out/bin/cockroach
  '';
}
