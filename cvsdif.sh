#! /bin/sh

if [ -d CVS.adm ]; then
  cvsTool=l2cvs
  for i in $*
  do
    j=`$cvsTool status $i | grep "RCS:" | cut -f2`
    $cvsTool diff -r$j $i
  done
else
  cvsTool=cvs
  for i in $*
  do
#    j=`$cvsTool status $i | grep RCS | cut -f2`
#    $cvsTool diff -r$j $i
    $cvsTool diff $i
  done
fi

