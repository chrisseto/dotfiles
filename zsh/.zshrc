#!/usr/bin/env zsh
# shortcut to this dotfiles path is $ZSH
export ZSH=$HOME/.dotfiles
export ANDROID_HOME=/usr/local/opt/android-sdk
export ANSIBLE_NOCOWS=1
export PATH=$PATH:~/scripts:~/.cabal/bin
export EDITOR='vim'
export OSF=~/code/cos/osf.io
export SCRAPI=~/code/cos/scrapi
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PYTHONPATH=$PYTHONPATH:/usr/local/lib/python
alias ansalon='telnet ansalonmud.net 8679'

source ~/dotfiles/tmux/tmuxinator.zsh

alias g='git'
alias gssh='SSH_AUTH_SOCK=~/.gnupg/S.gpg-agent.ssh && ssh'
alias c='clear'
alias query_share='curl -XPOST localhost:9200/share/_search\?pretty -d @query.json'
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

[[ -s $(brew --prefix)/etc/autojump.sh ]] && . $(brew --prefix)/etc/autojump.sh


export WORKON_HOME=~/Envs
source /usr/local/bin/virtualenvwrapper.sh
source /usr/local/opt/autoenv/activate.sh

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
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

zstyle ':vcs_info:*' enable git cvs svn

# or use pre_cmd, see man zshcontrib
vcs_info_wrapper() {
  vcs_info
  if [ -n "$vcs_info_msg_0_" ]; then
    echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
  fi
}
RPROMPT=$'$(vcs_info_wrapper)'
