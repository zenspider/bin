#!/bin/bash

check_up() {
    if gnuclient -batch -eval t >/dev/null 2>&1; then
      false;
    else
      echo starting xemacs
      xemacs -unmapped -f gnuserv-start &
      until gnuclient -batch -eval t >/dev/null 2>&1
      do
	sleep 1
      done
      sleep 1
    fi
    
}

e_normal() {
  gnuclient -q $*
}

e_text() {
  gnuclient -nw $*
}

check_up

case $TERM in
  *term* )
    e_normal $*
    ;;
  emacs )
    e_normal $*
    ;;
  vt* )
    e_text $*
    ;;
  sun )
    e_text $*
    ;;
  screen )
    e_text $*
    ;;
  dumb )
    e_text $*
    ;;
  dialup )
    e_text $*
    ;;
  *)
     echo "alias: don't know what to do for $TERM"
     ;;
esac
