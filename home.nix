{ config, pkgs, lib, ... }:

let hammerspoon = pkgs.callPackage ./hammerspoon/package.nix { };
in {
  # # Home Manager needs a bit of information about you and the
  # # paths it should manage.
  # home.username = "chrisseto";
  # home.homeDirectory = "/Users/chrisseto";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  home.packages = [
    pkgs.babelfish
    pkgs.direnv
    pkgs.fd
    pkgs.git
    pkgs.git-machete
    pkgs.go
    pkgs.neovim
    pkgs.nixfmt
    pkgs.ripgrep
    pkgs.tmux
    pkgs.vim
    pkgs.bazelisk
    pkgs.google-cloud-sdk
    pkgs.alacritty
    hammerspoon
  ];

  # The previous iteration of this repo was managed by stow. To ease
  # the transition, just symlink the old configurations.
  home.file.".tmux.conf".source = ./tmux/.tmux.conf;
  home.file.".gitconfig".source = ./git/.gitconfig;
  home.file.".gitignore_global".source = ./git/.gitignore_global;
  home.file.".config/fish".source = ./fish/.config/fish;
  home.file.".config/nvim".source = ./nvim/.config/nvim;
  home.file.".config/alacritty".source = ./alacritty;
  home.file.".hammerspoon".source = ./hammerspoon;

  # This should be removed once
  # https://github.com/nix-community/home-manager/issues/1341 is closed.
  disabledModules = [ "targets/darwin/linkapps.nix" ];
  home.activation.aliasApplications =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      app_folder="$(echo ~/Applications)/Home Manager Apps"
      home_manager_app_folder="$genProfilePath/home-path/Applications"
      $DRY_RUN_CMD rm -rf "$app_folder"
      # NB: aliasing ".../home-path/Applications" to "~/Applications/Home Manager Apps" doesn't
      #     work (presumably because the individual apps are symlinked in that directory, not
      #     aliased). So this makes "Home Manager Apps" a normal directory and then aliases each
      #     application into there directly from its location in the nix store.
      $DRY_RUN_CMD mkdir "$app_folder"
      for app in $(find "$newGenPath/home-path/Applications" -type l -exec readlink -f {} \;)
      do
        $DRY_RUN_CMD /usr/bin/osascript \
          -e "tell app \"Finder\"" \
          -e "make new alias file at POSIX file \"$app_folder\" to POSIX file \"$app\"" \
          -e "set name of result to \"$(basename $app)\"" \
          -e "end tell"
      done
    '';
}
