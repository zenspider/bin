#!/bin/bash

case `uname` in
    Darwin )
	    emacsclient -n -a cmacs $*
	    ;;
    *)
        emacsclient -n -a emacs $*
        ;;
esac
