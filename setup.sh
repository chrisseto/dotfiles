#!/usr/bin/env bash
set -xe  # Print out commands as they run and exit at first failure

if [ "$(uname)" == "Darwin" ]; then
  # http://marianposaceanu.com/articles/macos-sierra-upgrade-from-a-developers-perspective
  # https://discussions.apple.com/thread/7682417?start=0&tstart=0
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  defaults write NSGlobalDomain KeyRepeat -int 1
  defaults write NSGlobalDomain InitialKeyRepeat -int 12
fi

chsh -s $(which fish)
git submodule init
git submodule update
git submodule foreach git submodule init
git submodule foreach git submodule update

# Stops Stow from eating the .config directory
mkdir -p ~/.config/

# Add terminfo entries with 256color and italics support.
tic ./terminfo/tmux-256color.terminfo
tic ./terminfo/xterm-256color-italic.terminfo

# Use stow to link all our various dotfiles.
stow fish
stow nvim
stow git
stow tmux
