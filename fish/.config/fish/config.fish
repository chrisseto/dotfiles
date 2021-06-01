alias nv=nvim
alias g=git

# No Greeting when opening fish
set fish_greeting

export EDITOR='nvim'
export VISUAL='nvim'

# direnv hook (https://direnv.net/)
# Executes a .envrc file upon entering a directory
direnv hook fish | source

export GOPATH=$HOME/Go
