{ config, pkgs, ... }:

{
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

  home.packages = [
    pkgs.fd
    pkgs.git
    pkgs.neovim
    pkgs.nixfmt
    pkgs.ripgrep
    pkgs.tmux
    pkgs.vim
    pkgs.babelfish
    pkgs.git-machete
  ];

  # The previous iteration of this repo was managed by stow. To ease
  # the transition, just symlink the old configurations.
  home.file.".tmux.conf".source = ./tmux/.tmux.conf;
  home.file.".gitconfig".source = ./git/.gitconfig;
  home.file.".gitignore_global".source = ./git/.gitignore_global;
  home.file.".config/fish".source = ./fish/.config/fish;
  home.file.".config/nvim".source = ./nvim/.config/nvim;
}
