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

# Go-lang things
export GOPATH=$HOME/Go
export PATH=$PATH:$GOPATH/bin
export GOROOT="$(brew --prefix golang)/libexec"

export EDITOR='nvim'
export VISUAL='nvim'

# export TERM='xterm-256color-italic'  # Make colors work
export TERM='xterm-256color'  # Make colors work

# Java Stuff
export GROOVY_HOME=/usr/local/opt/groovy/libexec
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`

# Android Junk
export ANDROID_HOME="/usr/local/share/android-sdk"
export ANDROID_SDK_ROOT="/usr/local/share/android-sdk"
export ANDROID_NDK_HOME="/usr/local/share/android-ndk"
############ /ENV VARS ############


############ ALIASES ############
alias ipy="ipython"
alias pt="py.test"
alias py3="python3"
alias py="python"

alias g="git"
alias nv="nvim"

alias c="clear"
alias reload!="exec zsh"
# alias reload!="source ~/.zshrc"
alias fixterm="stty sane && tput reset"

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
# https://github.com/pyenv/pyenv-installer
export PATH="/Users/chrisseto/.pyenv/bin:$PATH"
# export CFLAGS="-I$(brew --prefix openssl)/include"
# export LDFLAGS="-L$(brew --prefix openssl)/lib"

if [ $commands[pyenv] ]; then
  export PYENV_ROOT="$HOME/.pyenv"

  eval "$(pyenv init -)"
  # Make virtual env add a prefix to the prompt
  eval "$(pyenv virtualenv-init -)"
fi

# Z autocomplete
# https://github.com/rupa/z
. `brew --prefix`/etc/profile.d/z.sh

# Rust up autocomplete
export PATH="$PATH:$HOME/.cargo/bin"

# RBenv autocomplete and shims
if [ $commands[rbenv] ]; then
  eval "$(rbenv init -)"
fi

# Node version manager
# export NVM_DIR="$HOME/.nvm"
# . "$(brew --prefix nvm)/nvm.sh"

# Kubectl autocomplete
if [ $commands[kubectl] ]; then
  source <(kubectl completion zsh)
fi

if [ $commands[helm] ]; then
  source <(helm completion zsh)
fi

# direnv hook (https://direnv.net/)
# Executes a .env file upon entering a directory
# Also appears to unload it
eval "$(direnv hook zsh)"
############ /3RD PARTY SETUP  ############

# Clear out duplicate $PATH entries
typeset -U PATH
