# Override pkgs.gopls to the latest version.
# See https://github.com/golang/tools/releases.
# Thanks to https://discourse.nixos.org/t/inconsistent-vendoring-in-buildgomodule-when-overriding-source/9225/7
self: super: {
  gopls = let
    version = "0.14.1";
    src = super.fetchFromGitHub {
      owner = "golang";
      repo = "tools";
      rev = "gopls/v${version}";
      sha256 = "sha256-efajbCeUXOU3Yv8TyAV0U59ubQgcA4kiIY11rP2z61E=";
    };
    vendorHash = "sha256-x8d+9CLCvg+PXC+EaWluUZ+QNynu+vzOA5xxYXcWNyw=";
  in
    super.gopls.override rec {
      buildGoModule = args:
        super.buildGoModule (args
          // {
            inherit src version vendorHash;
          });
    };
}
