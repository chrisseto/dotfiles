alias nv=nvim
alias g=git
alias bazel=bazelisk

# No Greeting when opening fish
set fish_greeting

set -gx EDITOR nvim
set -gx VISUAL nvim

# Set default XDG_*_HOME values as not everything knows how to provide the
# defaults.
set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_CONFIG_HOME $HOME/.config

# Properly setup go on MacOS and Linux distros
switch (uname)
	case Darwin
		set -gx GOPATH $HOME/Go
		fish_add_path $HOME/Go/bin
	case Linux
		set -gx GOPATH $HOME/go
		fish_add_path $HOME/go/bin
end

# Add any dotfile managed scripts/binaries.
fish_add_path -g $HOME/.bin

fish_add_path -g $HOME/.cargo/bin

# If we're on Apple Silicon, update our environment.
if test -x /opt/homebrew/bin/brew
	/opt/homebrew/bin/brew shellenv | source
end

# direnv hook (https://direnv.net/)
# Executes a .envrc file upon entering a directory
direnv hook fish | source

# Home manager support while this configuration isn't written by homemanager itself.
if test -f $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
	cat $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh | babelfish | source
end
