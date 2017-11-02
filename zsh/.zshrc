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


# typeset -U fpath
fpath=(~/.zsh/oc $fpath)

# Disable caps lock
# setxkbmap -option caps:swapescape

source ~/dotfiles/tmux/tmuxinator.zsh


alias g='git'
command -v vimx >/dev/null 2>&1 && alias vim='vimx'
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



export WORKON_HOME=~/Envs
if [[ -s "/usr/bin/virtualenvwrapper.sh" ]]; then
  source /usr/bin/virtualenvwrapper.sh
fi

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
alias spotify-online='ssh -f -N -D localhost:1080 localhost'
alias keep-trying='while [ $? -ne 0 ] ; do sleep 2 && $(fc -ln -1) ; done'
alias please='sudo $(fc -ln -1)'
alias yum='sudo dnf'
alias sssh='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias sscp='scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

function make_nfs_share {
  _path="/nfs_data/$1"
  if [ -d "$_path" ]
  then
    echo "$_path already exists"
    grep -q -e "$_path \*(rw)" /etc/exports || (echo "$_path *(rw)" | sudo tee -a /etc/exports)
    # skip
  else
    sudo mkdir -p $_path
    sudo chmod -R +755 $_path
    sudo chown -R 36:36 $_path
    grep -q -e "$_path \*(rw)" /etc/exports || (echo "$_path *(rw)" | sudo tee -a /etc/exports)
    echo "$_path share created"
  fi
  sudo exportfs -ra
}

if [[ -s "$(command -v activate.sh)" ]]; then
  source $(which activate.sh)
fi

# added by travis gem
[ -f /home/fabian/.travis/travis.sh ] && source /home/fabian/.travis/travis.sh

export NVM_DIR="/home/fabian/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# FASD configuration
eval "$(fasd --init auto)"
# Aliases: 
alias a='fasd -a'        # any
alias s='fasd -si'       # show / search / select
alias d='fasd -d'        # directory
alias f='fasd -f'        # file
alias sd='fasd -sid'     # interactive directory selection
alias sf='fasd -sif'     # interactive file selection
alias z='fasd_cd -d'     # cd, same functionality as j in autojump
alias j='fasd_cd -d'     # cd, same functionality as j in autojump
alias zz='fasd_cd -d -i' # cd with interactive selection
alias v='f -t -e vim -b viminfo'  # open file most recently edited in vim
alias vv='f -i -t -e vim'  # open file in vim
alias todo='todo -G'
export GOBIN=/home/fabian/Go/bin
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin

# source ~/.screen_layout/default.sh
