#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "Installing packages"
if [[ "$OSTYPE" == darwin* ]]; then
  brew install $(< packages.txt)
elif command -v dnf >/dev/null; then
  # fedora calls it vim-enhanced, and needs wl-clipboard for pbcopy/tmux copy
  sudo dnf install -y $(sed 's/^vim$/vim-enhanced/' packages.txt) wl-clipboard
fi

echo "Initializing submodules"
git submodule init
git submodule update
echo "Linking zsh configuration"
stow zsh
echo "Linking vim configuration"
stow vim
stow nvim
echo "Linking git configuration"
stow git
echo "Linking tmux configuration"
stow tmux
# echo "Installing tmuxinator"
# gem install --user-install tmuxinator
