#!/usr/bin/env zsh

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# initialize autocomplete here, otherwise functions won't be loaded
autoload -U compinit
compinit

# Make autoenv always work
# cd .
#
function colours() {
  for i in {0..255} ; do
      printf "\x1b[38;5;${i}mcolour${i}\n"
  done
}

export ANSIBLE_NOCOWS=1
export ANDROID_HOME=/usr/local/opt/android-sdk

export PATH=$PATH:~/.bin
# Go Lang things
export GOPATH=$HOME/Go
export PATH=$PATH:$GOPATH/bin
export GOVERSION=$(brew list go | head -n 1 | cut -d '/' -f 6)
export GOROOT=$(brew --prefix)/Cellar/go/$GOVERSION/libexec

export EDITOR=vim  # Screw nano

alias g='git'
alias c='clear'
alias flake="flake8"
alias nosetests="nosetests --rednose"
alias gssh='SSH_AUTH_SOCK=~/.gnupg/S.gpg-agent.ssh && ssh'
alias reload!='source ~/.zshrc'

autoload -U promptinit && promptinit

# Disable autocorrect
DISABLE_CORRECTION="true"
unsetopt correct
unsetopt correct_all

. ~/.bin/z.sh

alias py="python"
alias py3="python3"
alias ipy="ipython"
alias pyserv="python -m SimpleHTTPServer"
alias pyserv3="python3 -m http.server"
alias pt="py.test"
alias nt="nosetests"

# Conda environments
alias wo="workon"
alias de="deactivate"

alias nv="nvim"
export TERM='xterm-256color'

# Remove python compiled byte-code in either current directory or in a
# list of specified directories
function pyclean() {
    ZSH_PYCLEAN_PLACES=${*:-'.'}
    find ${ZSH_PYCLEAN_PLACES} -type f -name "*.py[co]" -delete
    find ${ZSH_PYCLEAN_PLACES} -type d -name "__pycache__" -delete
}


setopt no_share_history
unsetopt share_history
bindkey '^R' history-incremental-search-backward
bindkey '^E' end-of-line
bindkey '^A' beginning-of-line
