#!/usr/local/bin/bash

. ~/Bin/alias

#set -xv

#curdir=$PWD
curdir=`pwd`
displayhost='mom'

if [ $(uname) = "HP-UX" ] || [ $(uname) = "ncr" ]; then
  RSH="remsh"
else
  RSH="rsh"
fi

if [ ! -z "$DISPLAY" ]; then
  fndflcmd=x
else
  fndflcmd=xSame
fi

if [ $(hostname) != "$homehost" ]; then
  cmdhost="$RSH $displayhost"
else
  cmdhost=""
fi


for file in $*; do
  
  path=`expr "$file" : "\(.*\)\/[^\/]*"`
  if [ "$path" != "$curdir" ]; then
    file="$curdir/$file"
  fi
  
  eval "$cmdhost $fndflcmd $file" > /dev/null
  fndflcmd=xSame
  
done
