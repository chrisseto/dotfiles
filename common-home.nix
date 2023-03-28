{
  config,
  pkgs,
  lib,
  ...
}: {
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

  # Follow neovim nightly releases.
  # https://github.com/nix-community/neovim-nightly-overlay
  # nixpkgs.overlays = [
  #   (import (builtins.fetchTarball {
  #     url = "https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz";
  #   }))
  # ];

  home.packages = [
    pkgs.babelfish
    pkgs.bat
    pkgs.bazelisk
    pkgs.cargo
    pkgs.delve # golang debugger
    pkgs.fd
    pkgs.fzf
    pkgs.gdu # Ncurses interactive du client (Much faster than ncdu)
    pkgs.gh # GitHub CLI, slightly better than hub
    pkgs.git
    pkgs.git-machete
    pkgs.go_1_19 # Pin to 1.19 for as that's what we currently use.
    pkgs.gotools # Provides A LOT of packages. Added because I want godoc.
    pkgs.htop
    pkgs.jq
    pkgs.k9s # Kubernetes ncurses interface
    pkgs.kubectl
    pkgs.ncurses # Provides a terminfo database
    pkgs.neovim
    pkgs.nixfmt
    pkgs.ripgrep
    pkgs.terraform
    pkgs.tmux
    pkgs.tree
    pkgs.vault
  ];

  # Zoxide provides the "z" command for faster cd'ing around.
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;
  };

  # Fish configuration. See also https://nixos.wiki/wiki/Fish.
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # No Greeting when opening fish.
      set fish_greeting

      # Use Neovim as EDITOR.
      set -gx EDITOR nvim
      set -gx VISUAL nvim

      # Configurations for the pure fish prompt.
      set -U pure_enable_single_line_prompt true
      set -U pure_color_success green
      set -U pure_enable_container_detection false

       # Set default XDG_*_HOME values as not everything knows how to provide the
       # defaults.
       set -gx XDG_CACHE_HOME $HOME/.cache
       set -gx XDG_CONFIG_HOME $HOME/.config

       # Add ~/.bin to $PATH for access to custom scripts and the like.
       fish_add_path $HOME/.bin

       # Properly setup go on MacOS and Linux distros
       switch (uname)
       	case Darwin
       		set -Ux GOPATH $HOME/Go
       		fish_add_path $HOME/Go/bin
       	case Linux
       		set -Ux GOPATH $HOME/go
       		fish_add_path $HOME/go/bin
       end
    '';

    shellAliases = {
      nv = "nvim";
      g = "git";
    };

    plugins = [
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "pure";
        src = pkgs.fishPlugins.pure.src;
      }
      {
        name = "kubectl";
        src = pkgs.fetchFromGitHub {
          owner = "evanlucas";
          repo = "fish-kubectl-completions";
          rev = "ced676392575d618d8b80b3895cdc3159be3f628";
          sha256 = "sha256-OYiYTW+g71vD9NWOcX1i2/TaQfAg+c2dJZ5ohwWSDCc=";
        };
      }
      {
        name = "nix-env";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          sha256 = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
        };
      }
    ];
  };

  # The previous iteration of this repo was managed by stow. To ease
  # the transition, just symlink the old configurations.
  home.file.".bin".source = ./bin;
  home.file.".config/nvim".source = ./nvim/.config/nvim;
  home.file.".config/tmux".source = ./tmux;
  home.file.".gitconfig".source = ./git/.gitconfig;
  home.file.".gitignore_global".source = ./git/.gitignore_global;
}
