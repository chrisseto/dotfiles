{ lib
, stdenv
, darwin
, fetchFromGitHub
, rustPlatform
}:
rustPlatform.buildRustPackage rec {
  pname = "cooklang-chef";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "Zheoni";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-zst5dsRbSMP9b6XcWua3DFkQK9XjYytoxvbmhmkqTmk=";
  };

  cargoHash = "sha256-NH8LznrRHcv93wtI6i6kCLGmzGKnqsbQQN6UUTt42MQ=";

  buildInputs =
    [ ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      darwin.apple_sdk.frameworks.CoreServices
    ];

  meta = with lib; {
    description = "A CLI to manage cooklang recipes";
    homepage = "https://github.com/Zheoni/cooklang-chef";
  };
}
