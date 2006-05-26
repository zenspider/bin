#!/bin/sh

if [ $(id -u) != 0 ]; then
    echo "Please run this as root or with sudo"
    exit 1
fi

find ~ -name .DS_Store -print -exec rm "{}" \; 

rm -vrf \
    /System/Library/Extensions.kextcache \
    /Library/Caches/* \
    /System/Library/Caches/* \
    /private/var/db/BootCache.playlist \
    ~/Library/Caches/* \
    ~/Library/FontCollections/*.fcache \
    ~/Library/Preferences/LSApplications \
    ~/Library/Preferences/LSClaimedTypes \
    ~/Library/Preferences/LSSchemes \
    ~/Library/.LSApplications_Backup \
    ~/Library/Preferences/.LSClaimedTypes_Backup \
    ~/Library/Preferences/.LSSChemes_Backup \
    /.Spotlight-V100

reboot
