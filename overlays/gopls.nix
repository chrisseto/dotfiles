# Override pkgs.gopls to the latest version.
# See https://github.com/golang/tools/releases.
# Thanks to https://discourse.nixos.org/t/inconsistent-vendoring-in-buildgomodule-when-overriding-source/9225/7
self: super: {
  gopls = let
    version = "0.13.2";
    src = super.fetchFromGitHub {
      owner = "golang";
      repo = "tools";
      rev = "gopls/v${version}";
      sha256 = "sha256-fRpVAYg4UwRe3bcjQPOnCGWSANfoTwD5Y9vs3QET1eM=";
    };
    vendorSha = "sha256-9d7vgCMc1M5Cab+O10lQmKGfL9gqO3sajd+3rF5cums=";
  in
    super.gopls.override rec {
      buildGoModule = args:
        super.buildGoModule (args
          // {
            inherit src version vendorSha;
          });
    };
}
