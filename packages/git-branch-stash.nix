{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "git-branch-stash";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "gitext-rs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-aY2gHECrvCQ7zz8IrT11VXiMRpd8Y5XlpQs6oAB/k/s=";
  };

  cargoHash = "sha256-XaEnh1aDQctc67Tpp5/fIaduCfLdu5St8UulkW62NS4=";

  meta = with lib; {
    description = "Manage snapshots of your working directory";
    homepage = "https://github.com/gitext-rs/git-branch-stash";
  };
}
