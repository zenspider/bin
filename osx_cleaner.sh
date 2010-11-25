#!/bin/sh

if [ $(id -u) != 0 ]; then
    echo "Please run this as root or with sudo"
    exit 1
fi

EXTRA=

if [ "ls" == "$1" -o "full" == "$1" ]; then
  EXTRA=$EXTRA \
    ~/Library/Preferences/LSApplications \
    ~/Library/Preferences/LSClaimedTypes \
    ~/Library/Preferences/LSSchemes \
    ~/Library/.LSApplications_Backup \
    ~/Library/Preferences/.LSClaimedTypes_Backup \
    ~/Library/Preferences/.LSSChemes_Backup
fi

if [ "full" == "$1" ]; then
    mdutil -a -i off 
    mdutil -E -a -v
    rm -rf /Volumes/*/.Spotlight-V100
    mdutil -a -i on
fi

find ~ -name .DS_Store -print -exec rm "{}" \; 

rm -vrf \
    /Library/Caches/* \
    /System/Extensions/Caches/* \
    /System/Library/Caches/* \
    /System/Library/Extensions.kextcache \
    /System/Library/Extensions.mkext \
    /private/tmp/* \
    /private/var/db/BootCache.playlist \
    /private/var/folders/*/*/-Caches-/* \
    /private/var/folders/*/*/-Tmp-/* \
    /private/var/folders/*/*/TemporaryItems/* \
    /private/var/tmp/* \
    ~/Library/Caches/* \
    ~/Library/FontCollections/*.fcache \
    ~/Library/Mail/IMAP*/* \
    ~/Library/Safari/Icons/* \
    "~/Library/Preferences/Macromedia/Flash Player/macromedia.com" \
    "~/Library/Preferences/Macromedia/Flash Player/#SharedObjects" \
    $TMPDIR/../-*-/* \
    $EXTRA

reboot

echo "Cleaning System Caches..."
