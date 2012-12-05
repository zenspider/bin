#!/bin/sh

if [ $(id -u) != 0 ]; then
    echo "Please run this as root or with sudo"
    exit 1
fi

DONE=

if [ "full" == "$1" ]; then
    mdutil -a -i off 
    mdutil -E -a -v
    rm -rf /Volumes/*/.Spotlight-V100
    mdutil -a -i on
fi

locate -0 .DS_Store | xargs -0 rm
find ~ -name .DS_Store -print -exec rm "{}" \; 

rm -vrf \
    /Library/Caches/* \
    /System/Library/Caches/* \
    /private/tmp/* \
    /private/var/db/BootCache* \
    /private/var/folders/* \
    /private/var/tmp/* \
    /Users/*/Library/Caches/* \
    /Volumes/*/tmp/* \
    /Volumes/*/var/tmp/* \
    /Library/Preferences/SystemConfiguration/com.apple.PowerManagement.plist \
    ~/Library/Mail/V2/IMAP*/* \
    ~/Library/Safari/WebpageIcons.db \
    $DONE

reboot

echo "Cleaning System Caches..."
