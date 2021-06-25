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

# direnv hook (https://direnv.net/)
# Executes a .envrc file upon entering a directory
direnv hook fish | source
