{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "openscad-lsp";
  version = "v1.0.0";

  src = fetchFromGitHub {
    owner = "Leathong";
    repo = pname;
    rev = "472a55054dc7534d039d64b5515f426c62edf795";
    hash = "sha256-b+aUsE4PTU8WVyMpl2cw9+/BWixbmcsg7pRBuFajMLk=";
  };

  cargoHash = "sha256-IV/LZBCewbGJi8l/oOCnQRBrGAK5Lz7h5sGCSLVJqQ8=";

  meta = with lib; {
    description = "A LSP (Language Server Protocol) server for OpenSCAD";
    homepage = "https://github.com/Leathong/openscad-LSP";
  };
}
