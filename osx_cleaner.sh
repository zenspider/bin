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

rm -vrf \
    /Library/Preferences/SystemConfiguration/com.apple.PowerManagement.plist \
    /Volumes/*/Library/Caches/* \
    /Volumes/*/System/Extensions/Caches/* \
    /Volumes/*/System/Library/Caches/* \
    /Volumes/*/System/Library/Extensions.kextcache \
    /Volumes/*/System/Library/Extensions.mkext \
    /Volumes/*/System/Library/Extensions/Caches/* \
    /Volumes/*/Users/*/Library/Caches/* \
    /Volumes/*/Users/*/Library/Mail/V2/IMAP*/* \
    /Volumes/*/Users/*/Library/Safari/WebpageIcons.db \
    /Volumes/*/private/tmp/* \
    /Volumes/*/private/var/folders/*/*/-Caches-/* \
    /Volumes/*/private/var/folders/*/*/-Tmp-/* \
    /Volumes/*/private/var/folders/*/*/C/* \
    /Volumes/*/private/var/folders/*/*/T/* \
    /Volumes/*/private/var/folders/*/*/TemporaryItems/* \
    /Volumes/*/private/var/tmp/* \
    /Volumes/*/private/var/db/BootCache* \
    $DONE

reboot

echo "Cleaning System Caches..."
