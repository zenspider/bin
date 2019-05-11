#!/bin/bash

# if [[ -v INSIDE_EMACS ]]; then
#     export EDITOR="emacsclient"
# else
#     # Regular shell
#     export EDITOR="emacsclient -t"
# fi

case `uname` in
    Darwin )
        DIR=/MyApplications/Emacs.app/Contents/MacOS
        if [ -d $DIR ]; then
            $DIR/bin/emacsclient -n -a cmacs "$@"
        else
            emacsclient -n -a cmacs "$@"
        fi
	    ;;
    *)
        emacsclient -n -a emacs "$@"
        ;;
esac
