#!/bin/bash

exec emacs -nw -Q --eval "(setq frame-background-mode 'dark)" "$@"
