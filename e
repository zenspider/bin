#!/usr/local/bin/bash

check_up() {

  if [ ! -z ${DISPLAY-} ]; then
    if gnuclient -batch -eval t >/dev/null 2>&1; then
      false;
    else
      echo starting xemacs
      xemacs -unmapped &
      until gnuclient -batch -eval t >/dev/null 2>&1
      do
	sleep 1
      done
      sleep 1
    fi
  else
    echo "No display, not starting xemacs headless..."
  fi
}

e_normal() {
  gnuclient -q $*
}

e_text() {
  if [ -z ${DISPLAY-} ]; then
    echo "No display, running xemacs directly"
    xemacs -nw $*
  else
    echo "DISPLAY=$DISPLAY, running gnuclient"
    gnuclient -nw $*
  fi
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
  cons* )
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
