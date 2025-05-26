{ config
, pkgs
, lib
, unstable
, ...
}:
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
  nixpkgs.overlays = [
    (import ../overlays/janet)
  ];

  home.packages = [
    pkgs.age # age is a simple, modern and secure file encryption tool, format, and Go library.
    pkgs.bash # Install bash to ensure that shell scripts use nix binaries, not system binaries.
    pkgs.bat # Better `cat` with syntax highlighting
    pkgs.bazelisk
    pkgs.delta # Better git diff viewer
    pkgs.difftastic # Syntax aware differ
    pkgs.fastmod
    pkgs.fd # Better `find`. Broken on asahi due to jemalloc.
    pkgs.fzf # Pluggable fuzzy finder
    pkgs.gdu # Ncurses interactive du client (Much faster than ncdu)
    pkgs.gh # GitHub CLI, slightly better than hub
    pkgs.git
    pkgs.git-absorb
    pkgs.git-dive
    pkgs.git-revise
    pkgs.htop
    pkgs.hub # Old (?) GitHub CLI
    pkgs.ijq # Interactive version of jq for when you don't know what you're looking for
    pkgs.jq
    pkgs.k9s # Kubernetes ncurses interface
    pkgs.less # Ensure the latest version of less is available
    pkgs.ncurses # Install a recent version of ncurses to get an updated terminfo db
    pkgs.nnn # CLI file tree
    pkgs.ripgrep # `rg`, better grep/ag/ack
    pkgs.skim # `sk`, Competitor of fzf
    pkgs.tmux
    pkgs.tree # Prints a "tree" of a directory.
    pkgs.unixtools.watch
    pkgs.xz # LZMA compression successor, used by container tooling.
    unstable.delve # golang debugger
    unstable.go
    unstable.gotools # Provides A LOT of packages. Added because I want godoc.
    unstable.helix # A post-modern modal text editor
    unstable.nil # nix LSP.
    unstable.stgit # stacked-git, my preferred alternative to branches.
    unstable.yazi # Yet another file manager.
    (pkgs.janet.withPackages (ps:
      with ps; [
        sh
        spork
      ])) # A pretty neat lisp implementation
  ];

  # Zoxide provides the "z" command for faster cd'ing around.
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    stdlib = ''
      layout_poetry() {
        if [[ ! -f pyproject.toml ]]; then
          log_error 'No pyproject.toml found.  Use `poetry new` or `poetry init` to create one first.'
          exit 2
        fi

        local VENV=$(dirname $(poetry run which python))
        export VIRTUAL_ENV=$(echo "$VENV" | rev | cut -d'/' -f2- | rev)
        export POETRY_ACTIVE=1
        PATH_add "$VENV"
      }
    '';
  };

  # Bottom, `btm`, a different [h]top - https://github.com/ClementTsang/bottom
  programs.bottom = {
    enable = true;

    # Converted to TOML. Defaults: https://github.com/ClementTsang/bottom/blob/master/sample_configs/default_config.toml
    settings = {
      process_command = true;
    };
  };

  # Starip terminal prompt - https://starship.rs/config/
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      command_timeout = 750;

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

      # Use the new version of GCP's k8s auth.
      # https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
      set -gx USE_GKE_GCLOUD_AUTH_PLUGIN True

      # Set default XDG_*_HOME values as not everything knows how to provide the
      # defaults.
      set -gx XDG_CACHE_HOME $HOME/.cache
      set -gx XDG_CONFIG_HOME $HOME/.config

      # Configure a user local installation path for jpm.
      set -gx JANET_TREE $HOME/.local/jpm_tree

      # Configure `bat` as the pager for `man` https://github.com/sharkdp/bat?tab=readme-ov-file#man
      set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
      set -gx MANROFFOPT "-c"

      # Add ~/.bin to $PATH for access to custom scripts and the like.
      fish_add_path $HOME/.bin

      # For `cargo install`'d deps.
      fish_add_path $HOME/.cargo/bin

      # For `go install`'d deps.
      fish_add_path $(go env GOPATH)/bin

      # Homebrew's shell hook
      if type -q "/opt/homebrew/bin/brew"
        eval "$(/opt/homebrew/bin/brew shellenv)"
      end

      # Config completion for git-machete
      # ${pkgs.git-machete}/bin/git-machete completion fish | source
    '';

    shellAliases = {
      g = "git";
      less = "bat";
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
    ];
  };

  # The previous iteration of this repo was managed by stow. To ease
  # the transition, just symlink the old configurations.
  home.file.".config/tmux".source = ../assets/tmux;
  home.file.".gitconfig".source = ../assets/git/.gitconfig;
  home.file.".gitignore_global".source = ../assets/git/.gitignore_global;

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
  home.file.".bin".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixpkgs/assets/bin";
  home.file.".config/aerospace".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixpkgs/assets/aerospace";
  home.file.".config/helix".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixpkgs/assets/helix";
  home.file.".config/wezterm".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixpkgs/assets/wezterm";
  home.file.".config/alacritty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixpkgs/assets/alacritty";
  home.file.".config/fish/functions".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixpkgs/assets/fish-functions";
  home.file.".config/fish/completions".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixpkgs/assets/fish-completions";
}
