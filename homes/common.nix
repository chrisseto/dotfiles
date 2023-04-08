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

  home.packages = [
    pkgs.awscli # AWS ClI, for some reason split across v1 and v2. v2 doesn't want to install.
    pkgs.bat
    pkgs.bazelisk
    pkgs.cargo
    pkgs.delve # golang debugger
    pkgs.fd # Better `find`. Broken on asahi due to jemalloc.
    pkgs.fzf # Pluggable fuzzy finder
    pkgs.gdu # Ncurses interactive du client (Much faster than ncdu)
    pkgs.gh # GitHub CLI, slightly better than hub
    pkgs.git
    pkgs.git-machete
    pkgs.go_1_19 # Pin to 1.19 for as that's what we currently use.
    pkgs.gotools # Provides A LOT of packages. Added because I want godoc.
    pkgs.htop
    pkgs.ijq # Interactive version of jq for when you don't know what you're looking for
    pkgs.jq
    pkgs.k9s # Kubernetes ncurses interface
    pkgs.ncurses # Provides a terminfo database
    pkgs.neovim
    pkgs.nodejs
    pkgs.ripgrep # `rg`, better grep/ag/ack
    pkgs.terraform
    pkgs.tmux
    pkgs.tree
    pkgs.vault
    pkgs.yarn
  ];

  # Zoxide provides the "z" command for faster cd'ing around.
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;
  };

  # Starip terminal prompt - https://starship.rs/config/
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;

      format = "$username$hostname$localip$directory$git_branch$git_commit$git_state$git_metrics$git_status$package$nix_shell$sudo$cmd_duration$line_break$jobs$battery$time$status$os$shell$character";

      cmd_duration = {
        format = "[$duration]($style) ";
      };

      directory = {
        read_only = " ";
      };

      line_break = {
        disabled = true;
      };

      git_branch = {
        symbol = " ";
        format = "[$symbol$branch(:$remote_branch)]($style) ";
      };

      git_status = {
        format = "(\[$conflicted$modified$ahead_behind\]($style) )";
      };

      nix_shell = {
        symbol = " ";
      };
    };
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

       # Set default XDG_*_HOME values as not everything knows how to provide the
       # defaults.
       set -gx XDG_CACHE_HOME $HOME/.cache
       set -gx XDG_CONFIG_HOME $HOME/.config

       # Add ~/.bin to $PATH for access to custom scripts and the like.
       fish_add_path $HOME/.bin
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
  home.file.".bin".source = ../bin;
  home.file.".config/nvim".source = ../nvim/.config/nvim;
  home.file.".config/tmux".source = ../tmux;
  home.file.".gitconfig".source = ../git/.gitconfig;
  home.file.".gitignore_global".source = ../git/.gitignore_global;
}