alias nv=nvim
alias g=git

# No Greeting when opening fish
set fish_greeting

set -gx EDITOR nvim
set -gx VISUAL nvim

switch (uname)
	case Darwin
		set -gx GOPATH $HOME/Go
	case Linux
		set -gx GOPATH $HOME/go
end

# If we're on Apple Silicon, update our environment.
if test -x /opt/homebrew/bin/brew
	/opt/homebrew/bin/brew shellenv | source
end

# direnv hook (https://direnv.net/)
# Executes a .envrc file upon entering a directory
direnv hook fish | source
