{pkgs ? import <nixpkgs> {}}:
pkgs.buildGoModule {
  name = "crlfmt";

  src = pkgs.fetchFromGitHub {
    owner = "cockroachdb";
    repo = "crlfmt";
    rev = "461e8663b4b4887b1c6a6c9deaeeb775109a635f";
    sha256 = "sha256-kOuPEn4ggdhlhRH4eaizhLjPvNACbuaf+s0yNpclfFk=";
  };

  vendorHash = "sha256-mb1AJMhI0aimt8I/BrIrZ1kKjR5IFEen71WNgfRtFq4=";
}
