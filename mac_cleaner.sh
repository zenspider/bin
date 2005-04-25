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
    ~/Library/Prefereces/LSApplications \
    ~/Library/Prefereces/LSClaimedTypes \
    ~/Library/Prefereces/LSSchemes \
    ~/Library/.LSApplications_Backup \
    ~/Library/Prefereces/.LSClaimedTypes_Backup \
    ~/Library/Prefereces/.LSSChemes_Backup

reboot
