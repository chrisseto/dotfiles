# http://marianposaceanu.com/articles/macos-sierra-upgrade-from-a-developers-perspective
# https://discussions.apple.com/thread/7682417?start=0&tstart=0
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 12

chsh -s /bin/zsh
git submodule init
git submodule update
stow zsh
stow nvim
stow git
stow tmux
