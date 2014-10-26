#!/usr/bin/env zsh
# shortcut to this dotfiles path is $ZSH
export ZSH=$HOME/.dotfiles
export ANDROID_HOME=/usr/local/opt/android-sdk
export ANSIBLE_NOCOWS=1
#
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
