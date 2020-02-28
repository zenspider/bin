#!/bin/bash

set -xv

# if [[ -v INSIDE_EMACS ]]; then
#     export EDITOR="emacsclient"
# else
#     # Regular shell
#     export EDITOR="emacsclient -t"
# fi

case $(uname) in
    Darwin )
        # MY_APP_DIR defined in Bin/Config/os/Darwin
        DIR="${MY_APP_DIR}/Emacs.app/Contents/MacOS"
        EMACSCLIENT="${DIR}/bin/emacsclient"
        ALT=cmacs
	;;
    *)
        EMACSCLIENT=emacsclient
        ALT=emacs
        ;;
esac

if [ -n "#{SSH_CLIENT:-}" ]; then
    $EMACSCLIENT -a $ALT "$@"
else
    # just let the PATH deal with it
    emacs -q "$@"
fi
