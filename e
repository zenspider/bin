#!/bin/bash

# set -xv

# This script assumes emacs and emacsclient are available from
# Emacs.app via symlink and/or in the path.

if [ -n "${INSIDE_EMACS:-}" ]; then
    exec emacsclient "$@"
fi

if [ -z "${SSH_CLIENT:-}" ]; then
    for f in $TMPDIR/emacs*/server ; do
        if [ -f "$f" ]; then
            echo $f
            exec emacsclient "$@"
        fi
    done
fi

EMACS="emacs -nw --eval \"(setq frame-background-mode 'dark)\""

exec emacsclient -a "$EMACS" "$@"
