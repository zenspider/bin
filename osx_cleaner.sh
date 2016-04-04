#!/bin/sh

if [ $(id -u) != 0 ]; then
    echo "Please run this as root or with sudo"
    exit 1
fi

DONE=

if [ "full" == "$1" ]; then
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
    /Library/Caches/* \
    /System/Library/Caches/* \
    /System/Library/Extensions.kextcache \
    /System/Library/Extensions.mkext \
    /System/Library/Extensions/Caches/* \
    /private/tmp/* \
    /private/var/db/BootCache.playlist \
    /private/var/db/BootCache* \
    /private/var/folders/*/*/-Caches-/* \
    /private/var/folders/*/*/-Tmp-/* \
    /private/var/folders/*/*/C/* \
    /private/var/folders/*/*/T/* \
    /private/var/folders/*/*/TemporaryItems/* \
    /private/var/tmp/* \
    /Users/*/Library/Caches/* \
    /Volumes/*/tmp/* \
    /Volumes/*/var/tmp/* \
    /Library/Preferences/SystemConfiguration/com.apple.PowerManagement.plist \
    ~/Library/Mail/V2/IMAP*/* \
    ~/Library/Safari/WebpageIcons.db \
    $DONE

# TODO?
# /bin/rm /var/db/SystemConfiguration/com.apple.PowerManagement.xml
# /bin/rm /Library/Preferences/SystemConfiguration/com.apple.PowerManagement.plist

reboot

echo "Cleaning System Caches..."
