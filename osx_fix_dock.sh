#!/bin/bash

defaults write com.apple.dock pinning -string start
defaults write com.apple.dock no-glass -boolean YES
defaults delete com.apple.dock persistent-apps
killall Dock
defaults write com.apple.Finder QuitMenuItem -boolean YES
defaults write com.apple.finder QLEnableXRayFolders -boolean YES
killall Finder
defaults write com.apple.iphoto MapScrollWheel -bool YES

sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "Property of Ryan Davis - 206.999.9936"
