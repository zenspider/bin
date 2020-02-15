#!/bin/bash

if [ "$(id -u)" != 0 ]; then
    echo "Please run this as root or with sudo"
    exit 1
fi

DONE=

if [ "full" = "$1" ]; then
    mdutil -a -i off 
    mdutil -E -a -v
    launchctl unload -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist
    rm -rf /Volumes/*/.Spotlight-V100
    launchctl load -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist
    mdutil -a -i on
fi

locate -0 .DS_Store | xargs -0 rm
find ~ -name .DS_Store -print -exec rm "{}" \; 
find /Volumes/*/Users/*/Library/Safari/LocalStorage -mtime +52w -print -delete

rm -vrf \
    $(grep -l IMAP4 ~/Library/Mail/V6/*/.mboxCache.plist | xargs -n 1 dirname) \
    /Library/Updates/* \
    /Volumes/*/Library/Caches/* \
    /Volumes/*/System/Library/Caches/* \
    /Volumes/*/Users/*/Library/Caches/* \
    ~/Library/Caches/com.apple.appstore/* \
    ~/Library/Caches/com.apple.appstoreagent/* \
    /Volumes/*/private/tmp/* \
    /Volumes/*/private/var/folders/*/*/C/* \
    /Volumes/*/private/var/folders/*/*/T/* \
    /Volumes/*/private/var/tmp/* \
    $DONE

reboot

echo "Cleaning System Caches..."
