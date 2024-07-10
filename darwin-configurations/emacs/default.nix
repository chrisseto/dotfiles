{ config
, pkgs
, lib
, unstable
, ...
}:
{
  # homebrew = {
  #   enable = true;
  #
  #   taps = [ "d12frosted/emacs-plus" ];
  #
  #   brews = [
  #     {
  #       name = "emacs-plus";
  #       args = [
  #         "with-imagemagick"
  #         "with-no-frame-refocus"
  #         "with-native-comp"
  #         "with-savchenkovaleriy-big-sur-icon"
  #       ];
  #     }
  #   ];
  # };

  home-manager.users.chrisseto = {
    imports = [
      ({ config, pkgs, lib, ... }: {
        # TODO enable native comp
        # TODO Wrap emacs with something that namespaces tools like fd to just it?
        home.packages = [
          pkgs.fd # Faster file listing
          pkgs.fontconfig
          pkgs.git # Used to install doom emacs
          pkgs.ispell # For spell checking
          pkgs.ripgrep # Faster file searching
          unstable.emacs-macport
        ];

        # Ensure that the doom executable is available in $PATH
        programs.fish =
          {
            interactiveShellInit = ''
              fish_add_path $HOME/.config/emacs/bin
            '';

            shellAliases = {
              em = "emacs -nw";
            };
          };

        home.file.".config/doom".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixpkgs/home-modules/emacs/doom";

        # Doom emacs wants to write to a .local file in its install directory (Though
        # that might change in the future). Instead, we have to settle on using a
        # hook to ensure that we've git cloned it and then run `doom sync`.
        # TODO: Pinning to a specific ref/sha may be good for reproducibility.
        home.activation.installDoomEmacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          		# Ensure that emacs and git are in $PATH for doom/straight.el to
          		# execute.
          		# TODO Figure out how to reference homebrew.Prefix from nix-darwin here.
          		PATH="${pkgs.git}/bin:${pkgs.emacs-macport}/bin:$PATH"

          		if ! [[ -d "$HOME/.config/emacs" ]]; then 
          			run ${pkgs.git}/bin/git clone --depth 1 https://github.com/doomemacs/doomemacs $HOME/.config/emacs
          			run $HOME/.config/emacs/bin/doom install --no-config --no-env --no-fonts
          		fi

          		run $HOME/.config/emacs/bin/doom sync -e --force
        '';
      })
    ];
  };
}
