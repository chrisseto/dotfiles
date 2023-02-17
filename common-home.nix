{ config, pkgs, lib, ... }:

{
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
    pkgs.bazelisk
    pkgs.direnv
    pkgs.fd
    pkgs.git
    pkgs.git-machete
    pkgs.go
    pkgs.neovim
    pkgs.nixfmt
    pkgs.ripgrep
    pkgs.tmux
    pkgs.zoxide
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = (builtins.readFile ./fish/.config/fish/config.fish);

    functions = {
      fish_prompt =
        (builtins.readFile ./fish/.config/fish/functions/fish_prompt.fish);
      fish_right_prompt = (builtins.readFile
        ./fish/.config/fish/functions/fish_right_prompt.fish);
    };

    plugins = [{
      name = "nix-env";
      src = pkgs.fetchFromGitHub {
        owner = "lilyball";
        repo = "nix-env.fish";
        rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
		sha256 = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
      };
    }];

  };

  # The previous iteration of this repo was managed by stow. To ease
  # the transition, just symlink the old configurations.
  home.file.".gitconfig".source = ./git/.gitconfig;
  home.file.".gitignore_global".source = ./git/.gitignore_global;
  home.file.".config/nvim".source = ./nvim/.config/nvim;
  home.file.".config/tmux".source = ./tmux;
}
