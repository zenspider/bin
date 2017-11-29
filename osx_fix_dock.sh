#!/bin/bash

# oh god do I hate tooltips
defaults write -g NSInitialToolTipDelay -int 30000

defaults write com.apple.dock pinning -string start
defaults write com.apple.dock autohide -boolean YES
defaults write com.apple.dock no-glass -boolean YES
defaults write com.apple.dock use-new-list-stack -boolean yes
defaults write com.apple.dock expose-animation-duration -float 0.15
defaults write com.apple.dock double-tap-jump-back -bool TRUE
defaults write com.apple.dock autohide-time-modifier -float 0.12
defaults delete com.apple.dock persistent-apps
killall Dock

defaults write com.omnigroup.OmniFocus RelativeDateFormatterShowTime YES
defaults write com.omnigroup.OmniFocus RelativeDateFormatterDefaultWantsTruncatedTime NO
defaults write com.omnigroup.OmniFocus RelativeDateFormatterUseRelativeDayNames YES
defaults write com.omnigroup.OmniFocus RelativeDateFormatterDateFormatStyle short

defaults write com.apple.finder QuitMenuItem -bool YES
defaults write com.apple.finder QLEnableXRayFolders -bool YES
killall Finder

defaults write com.apple.iphoto MapScrollWheel -bool YES
killall iPhoto

defaults write com.apple.iTunes show-store-link-arrows -bool YES
defaults write com.apple.iTunes show-store-arrow-links -bool YES
killall iTunes

defaults write com.apple.screencapture disable-shadow -bool true

echo "running sudo to set preferences and hostname"
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "Property of Ryan Davis - 206.999.9936"
FULLNAME=wrath.zenspider.com
sudo hostname $FULLNAME
sudo scutil --set HostName $FULLNAME>

sudo defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

defaults write -g NSRecentDocumentsLimit -int 10

defaults write com.google.Keystone.Agent checkInterval 0

echo "fixing keychain support for ssh keys:"

/usr/bin/ssh-add -KA # ~/.ssh/id_rsa
