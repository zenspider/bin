#!/usr/local/bin/bash

#set -xv
set -u

pid=$$

if [ $# -ne 1 ]; then
  F1=/tmp/chk$pid
else
  F1=$1
fi

rm -f $F1

Q='"'

while read line; do

# Find lines beginning with and containing a single word

  file=`echo $line | sed -n '/^[A-Za-z0-9][-A-Za-z0-9\.\/\_]*[ 	]*$/p'`

  if [ "x$file" != "x" ]; then

    morefile=1
    while [ $morefile -eq 1 ]; do

      read line
      ff=`echo $line | sed -n '/^[A-Za-z0-9][-A-Za-z0-9\.\/\_]*[ 	]*$/p'`

      if [ "x$ff" != "x" ]; then
        file="$file $ff"
      else
        morefile=0
      fi

    done

    comment=""
    more=1
    while [ $more -eq 1 ]; do

      more=0
      if read line; then
        if [ "x$line" != "x" ]; then
	  more=1
	  line=`echo $line | sed -e 's/\$\(.\)/\\\\\$\1/g' -e 's/"/\\\\"/g'`
          if [ "x$comment" = "x" ]; then
	    comment=$line
          else
            comment=`echo "$comment"; echo "$line"`
          fi
	fi
      fi

    done

    echo $cvsTool commit -m "$Q$comment$Q" $file >> $F1
  fi
done
