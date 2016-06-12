#!/usr/bin/env zsh
# shortcut to this dotfiles path is $ZSH
export ZSH=$HOME/.dotfiles
export ANSIBLE_NOCOWS=1
export PATH=$PATH:~/scripts:~/.cabal/bin
export SHELL='/usr/bin/zsh'
export EDITOR='vim'
export OSF=~/code/cos/osf.io
export SCRAPI=~/code/cos/scrapi
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PYTHONPATH=$PYTHONPATH:/usr/local/lib/python
alias ansalon='telnet ansalonmud.net 8679'

# Disable caps lock
setxkbmap -option caps:none

source ~/dotfiles/tmux/tmuxinator.zsh
[[ -s /etc/profile.d/autojump.zsh ]] && source /etc/profile.d/autojump.zsh


alias g='git'
[[ `command -v vimx` ]] && alias vim='vimx'
alias gssh='SSH_AUTH_SOCK=~/.gnupg/S.gpg-agent.ssh && ssh'
alias c='clear'
alias mkpasswd='python -c "from passlib.hash import sha512_crypt; import getpass; print sha512_crypt.encrypt(getpass.getpass())"'
# use .localrc for SUPER SECRET CRAP that you don't
# want in your public, versioned repo.
if [[ -a ~/.localrc ]]
then
  source ~/.localrc
fi

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# initialize autocomplete here, otherwise functions won't be loaded
autoload -U compinit
compinit

# Make autoenv always work
cd .
# fortune -o -s -n 300 | cowsay -f dragon-and-cow | lolcat

# [[ -s $(brew --prefix)/etc/autojump.sh ]] && . $(brew --prefix)/etc/autojump.sh


export WORKON_HOME=~/Envs
if [[ -s "/usr/bin/virtualenvwrapper.sh" ]]; then
  source /usr/bin/virtualenvwrapper.sh
fi
# source /usr/local/opt/autoenv/activate.sh

pyclean () {
        ZSH_PYCLEAN_PLACES=${*:-'.'}
        noglob find ${ZSH_PYCLEAN_PLACES} -type f -name "*.py[co]" -delete
        noglob find ${ZSH_PYCLEAN_PLACES} -type d -name "__pycache__" -delete
}

# added by travis gem
[ -f /Users/fabian/.travis/travis.sh ] && source /Users/fabian/.travis/travis.sh

# Show git branch
setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' actionformats \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats       \
    '%F{4}%s%F{3}%F{2}:%F{4}%F{2}%b%F{5}%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

zstyle ':vcs_info:*' enable git cvs svn

# or use pre_cmd, see man zshcontrib
vcs_info_wrapper() {
  vcs_info
  if [ -n "$vcs_info_msg_0_" ]; then
    echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
  fi
}

venv_info_wrapper() {
    if [ -n "$VIRTUAL_ENV" ]; then
        local _virtualenv_path
        _virtualenv_path=(${(s:/:)VIRTUAL_ENV})
        echo "($_virtualenv_path[-1])"
    fi
}

dir_info_wrapper() {
    local _cwd
    local _dir
    local _path
    local _dirs
    local _under_home
    local _path_pieces
    _path_pieces=()
    _under_home=false
    _cwd="$(pwd)"

    if [[ "$_cwd" =~ ^"$HOME"(/|$) ]]; then
        _cwd="~${$(pwd)#$HOME}"
        _under_home=true
    fi

    _dirs=(${(s:/:)_cwd})

    for _dir in $_dirs; do
        _path_pieces+="$_dir[1]"
    done

    _path_pieces[-1]=$_dirs[-1]

    for _piece in $_path_pieces; do
        _path+="/$_piece"
    done

    if [ "$_path" = "" ]; then
        _path='/'
    fi

    if [ "$_under_home" = true ]; then
        _path[1]=""
    fi

    echo "$_path"
}

PROMPT='$(venv_info_wrapper)%F{6}$(dir_info_wrapper)%f %F{9}❯%F{3}❯%F{2}❯%f '
RPROMPT=$'$(vcs_info_wrapper)'

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
# export GOVERSION=$(brew list go | head -n 1 | cut -d '/' -f 6)
# export GOROOT=$(brew --prefix)/Cellar/go/$GOVERSION/libexec

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

# . ~/.bin/z.sh

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

if which ruby >/dev/null && which gem >/dev/null; then
    PATH="$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi

export VAGRANT_DEFAULT_PROVIDER=libvirt
unset GREP_OPTIONS
alias npm-exec='PATH=$(npm bin):$PATH'
alias go-exec='PATH=$GOPATH/bin:$PATH'

setopt clobber
alias rhciag='ag -l --silent --ignore fusor/fusor-ember-cli --ignore fusor/ui --ignore \*.po'
alias spotify-online='ssh -N -D localhost:1080 localhost'
alias keep-trying='while [ $? -ne 0 ] ; do sleep 2 && $(fc -ln -1) ; done'
alias please='sudo $(fc -ln -1)'
alias yum='sudo dnf'
alias sssh='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias sscp='scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
