# jip: stacked pull requests for jj (https://github.com/omarkohl/jip).
# Bump with: nix run nixpkgs#nix-update -- --flake jip (see README).
{ lib
, buildGoModule
, fetchFromGitHub
}:
buildGoModule rec {
  pname = "jip";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "omarkohl";
    repo = "jip";
    rev = "v${version}";
    hash = "sha256-mg2/3slhdRuIWKQj2xmRcvMb5ZZxRHPbyJc5mKaUk3c=";
  };

  vendorHash = "sha256-FgviIMQm6oKzWPh2pXWDpHUoS3ylHfQCxiwV6jjO+kY=";

  subPackages = [ "." ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/omarkohl/jip/cmd.Version=${version}"
  ];

  # Integration tests need jj/git and network access.
  doCheck = false;

  meta = {
    description = "Stacked pull requests for Jujutsu (jj)";
    homepage = "https://github.com/omarkohl/jip";
    license = lib.licenses.mit;
    mainProgram = "jip";
  };
}
