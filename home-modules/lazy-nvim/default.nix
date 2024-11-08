{ config
, pkgs
, unstable
, ...
}:
{

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # TODO does this work in fish?
  home.shellAliases = {
    nv = "nvim";
  };

  home.packages = [
    unstable.neovim # Gotta use the bleeding edge.
    pkgs.ncurses # Install a recent version of ncurses to get an updated terminfo db

    # Utilities used by plugins.
    pkgs.bat # Better `cat` with syntax highlighting
    pkgs.git
    pkgs.ripgrep # `rg`, better grep/ag/ack
    pkgs.fd # ` better find
  ];


  # Use (abuse?) a helper in home manager to symlink directly to the config
  # file within the repository. This allows programs to modify ~/.config
  # directly and have those changes get tracked by this respository. On the
  # downside, this repository MUST be cloned to ~/.nixpkgs to work correctly,
  # which is a bit less than ideal.
  # See https://github.com/nix-community/home-manager/issues/2085
  # It may be preferable to instead use something that ensures ~/.nixpkgs
  # exists as a git repository (not changing it if it already exists!!) which
  # would allow this type of symlinking to be acceptable..
  # See https://www.foodogsquared.one/posts/2023-03-24-managing-mutable-files-in-nixos/
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixpkgs/home-modules/lazy-nvim/assets";

}