#!/bin/bash

# oh god do I hate tooltips
defaults write -g NSInitialToolTipDelay -int 30000

defaults write com.apple.dock pinning -string start
defaults write com.apple.dock autohide -boolean YES
defaults write com.apple.dock no-glass -boolean YES
defaults write com.apple.dock use-new-list-stack -boolean yes
defaults delete com.apple.dock persistent-apps
killall Dock

defaults write com.omnigroup.OmniFocus RelativeDateFormatterShowTime YES
defaults write com.omnigroup.OmniFocus RelativeDateFormatterDefaultWantsTruncatedTime NO
defaults write com.omnigroup.OmniFocus RelativeDateFormatterUseRelativeDayNames YES
defaults write com.omnigroup.OmniFocus RelativeDateFormatterDateFormatStyle short

defaults write com.apple.Finder QuitMenuItem -boolean YES
defaults write com.apple.finder QLEnableXRayFolders -boolean YES
killall Finder

defaults write com.apple.iphoto MapScrollWheel -bool YES
killall iPhoto

defaults write com.apple.iTunes show-store-link-arrows -bool YES
defaults write com.apple.iTunes show-store-arrow-links -bool YES
killall iTunes

defaults write com.apple.screencapture disable-shadow -bool true

sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "Property of Ryan Davis - ATTi - 206.999.9936"

defaults write -g NSRecentDocumentsLimit -int 10
