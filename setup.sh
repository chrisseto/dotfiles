echo "Initializing submodules"
git submodule init
git submodule update
echo "Linking zsh configuration"
stow zsh
echo "Linking vim configuration"
stow vim
echo "Linking git configuration"
stow git
echo "Linking tmux configuration"
stow tmux
echo "Installing tmuxinator"
gem install --user-install tmuxinator
