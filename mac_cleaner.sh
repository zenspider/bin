#!/bin/sh

if [ $(id -u) != 0 ]; then
    echo "Please run this as root or with sudo"
    exit 1
fi

rm -rf \
    /System/Library/Extensions.kextcache \
    /Library/Caches/* \
    /System/Library/Caches/* \
    /private/var/db/BootCache.playlist \
    ~/Library/Caches/* \
    ~/Library/FontCollections/*.fcache

reboot