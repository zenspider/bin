defaults write com.apple.dock pinning -string start
defaults write com.apple.dock no-glass -boolean YES
defaults delete com.apple.dock persistent-apps
killall Dock
defaults write com.apple.Finder QuitMenuItem -boolean YES
killall Finder

