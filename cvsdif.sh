#! /bin/sh

cvsTool=cvs
for i in $*
do
  $cvsTool diff $i
done

