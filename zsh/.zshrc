#!/usr/bin/env zsh

############ ZSH SETUP ############
# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# initialize autocomplete here, otherwise functions won't be loaded
autoload -U compinit && compinit
autoload -U promptinit && promptinit

# Disable autocorrect
DISABLE_CORRECTION="true"
unsetopt correct
unsetopt correct_all

setopt no_share_history
unsetopt share_history

bindkey '^R' history-incremental-search-backward
bindkey '^E' end-of-line
bindkey '^A' beginning-of-line

############ /ZSH SETUP ############



############ ENV VARS ############
export ANSIBLE_NOCOWS=1

export PATH=$PATH:~/.bin

# Go Lang things
export GOPATH=$HOME/Go export PATH=$PATH:$GOPATH/bin
export GOVERSION=$(brew list go | head -n 1 | cut -d '/' -f 6)
export GOROOT=$(brew --prefix)/Cellar/go/$GOVERSION/libexec

export EDITOR=nvim

export TERM='xterm-256color'  # Make colors work right

############ /ENV VARS ############



############ ALIASES ############
alias ipy="ipython"
alias pt="py.test"
alias py3="python3"
alias py="python"

alias g="git"
alias nv="nvim"

alias c="clear"
alias reload!="source ~/.zshrc"

############ /ALIASES ############



############ FUNCTIONS  ############
# Remove python compiled byte-code in either current directory or in a
# list of specified directories
function pyclean() {
    ZSH_PYCLEAN_PLACES=${*:-'.'}
    find ${ZSH_PYCLEAN_PLACES} -type f -name "*.py[co]" -delete
    find ${ZSH_PYCLEAN_PLACES} -type d -name "__pycache__" -delete
}

function colours() {
  for i in {0..255} ; do
      printf "\x1b[38;5;${i}mcolour${i}\n"
  done
}
############ /FUNCTIONS  ############



############ 3RD PARTY SETUP  ############
# pyenv setup
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
# Make virtual env add a prefix to the prompt
eval "$(pyenv virtualenv-init -)"

# Z autocomplete
# https://github.com/rupa/z
. `brew --prefix`/etc/profile.d/z.sh


# Node version manager
export NVM_DIR="$HOME/.nvm"
. "$(brew --prefix nvm)/nvm.sh"
[[ -r $NVM_DIR/bash_completion ]] && . $NVM_DIR/bash_completion

# Kubectl autocomplete
if [ $commands[kubectl] ]; then
  source <(kubectl completion zsh)
fi
############ /3RD PARTY SETUP  ############
