#!/bin/bash

# set -xv

# This script assumes emacs and emacsclient are available from
# Emacs.app via symlink and/or in the path.

if [ -n "${SSH_CLIENT:-}" ]; then
    exec emacsclient -a "emacs -nw -q" -t "$@"
fi

if [ -n "${INSIDE_EMACS:-}" ]; then
    exec emacsclient "$@"
fi

exec emacsclient -a emacs "$@"
