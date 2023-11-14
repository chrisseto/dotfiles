{
  config,
  pkgs,
  lib,
  unstable,
  ...
}: let
  cockroachdb = pkgs.callPackage ../packages/cockroachdb.nix {};
in {
  home.packages = [
    cockroachdb
    pkgs.alacritty
    pkgs.reattach-to-user-namespace
  ];

  home.file.".hammerspoon".source = ../assets/hammerspoon;
  home.file.".config/alacritty".source = ../assets/alacritty;

  # This should be removed once
  # https://github.com/nix-community/home-manager/issues/1341 is closed.
  # disabledModules = [ "targets/darwin/linkapps.nix" ];
  # home.activation.aliasApplications =
  #   lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #     app_folder="$(echo ~/Applications)/Home Manager Apps"
  #     home_manager_app_folder="$genProfilePath/home-path/Applications"
  #     $DRY_RUN_CMD rm -rf "$app_folder"
  #     # NB: aliasing ".../home-path/Applications" to "~/Applications/Home Manager Apps" doesn't
  #     #     work (presumably because the individual apps are symlinked in that directory, not
  #     #     aliased). So this makes "Home Manager Apps" a normal directory and then aliases each
  #     #     application into there directly from its location in the nix store.
  #     $DRY_RUN_CMD mkdir "$app_folder"
  #     for app in $(find "$newGenPath/home-path/Applications" -type l -exec readlink -f {} \;)
  #     do
  #       $DRY_RUN_CMD /usr/bin/osascript \
  #         -e "tell app \"Finder\"" \
  #         -e "make new alias file at POSIX file \"$app_folder\" to POSIX file \"$app\"" \
  #         -e "set name of result to \"$(basename $app)\"" \
  #         -e "end tell"
  #     done
  #   '';
}
