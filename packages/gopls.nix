# Pulled from https://github.com/NixOS/nixpkgs/blob/nixos-23.05/pkgs/development/tools/language-servers/gopls/default.nix#L23
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "gopls";

  # See https://github.com/golang/tools/releases. Note the lack of a preceding 'v'.
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "golang";
    repo = "tools";
    rev = "gopls/v${version}";
    sha256 = "sha256-2eGnctA5HlNRGv9iV5HoT4ByA8fK/mTxldHll0UMD5c=";
  };

  modRoot = "gopls";
  vendorSha256 = "sha256-2H8Qh88ikmEqToGOCOoovcCh3dMToeFP/GavG9dlML8=";

  doCheck = false;

  # Only build gopls, and not the integration tests or documentation generator.
  subPackages = ["."];

  meta = with lib; {
    description = "Official language server for the Go language";
    homepage = "https://github.com/golang/tools/tree/master/gopls";
    license = licenses.bsd3;
  };
}
