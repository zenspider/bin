#!/usr/local/bin/bash

#set -xv
set -u

pid=$$

# Check for a -n argument: no edit
edit=1
while getopts "n" opt; do
  case $opt in
    n ) 
      edit=0
      ;;
  esac
done
shift $(($OPTIND - 1))

UPDATELOG=update.log
MODIFIED=/tmp/mc$pid
ADDED=/tmp/a$pid
REMOVED=/tmp/r$pid
UNKNOWN=/tmp/un$pid
DIFFS=/tmp/c$pid

# This is the file that is created by this script, and presented for editing

COMMENTS=checkin.data
INPUT=checkin.input

cvsTool=cvs

echo "cvs update ..."
rm -f $UPDATELOG
$cvsTool update $* > $UPDATELOG
cat $UPDATELOG

# -----------------------
if [ -d CVS.adm ]; then
# old cvs tools 
sed -n '/^[MC] /p' $UPDATELOG | \
  sed 's/^[MC] \([^ ]*\) .*$/\1/' > $MODIFIED
# 
else
# new tools
sed -n '/^M /p' $UPDATELOG | \
  sed 's/^M \([^ ]*\)$/\1/' > $MODIFIED
sed -n '/^C /p' $UPDATELOG | \
  sed 's/^C \([^ ]*\)$/\1/' >> $MODIFIED
#
fi
# -----------------------

sed -n '/^A /p' $UPDATELOG | \
  sed 's/^A \([^ ]*\)$/\1/' > $ADDED

sed -n '/^R /p' $UPDATELOG | \
  sed 's/^R \([^ ]*\)$/\1/' > $REMOVED

sed -n '/^\? /p' $UPDATELOG | \
  sed 's/^\? \([^ ]*\)$/\1/' > $UNKNOWN

rm -f $DIFFS
touch $DIFFS

echo "cvs diff ..."
if [ -s $MODIFIED ]; then
  for i in `cat $MODIFIED`
  do
    echo "============" >> $DIFFS
    echo "diffing $i"
    echo >> $DIFFS
    echo $i >> $DIFFS
    echo >> $DIFFS
    cvsdif.sh $i >> $DIFFS
    echo >> $DIFFS
  done
fi

if [ -s $ADDED ]; then
  for i in `cat $ADDED`
  do
    echo $i >> $DIFFS
    echo >> $DIFFS
    echo "  Added." >> $DIFFS
    echo >> $DIFFS
  done
fi

if [ -s $REMOVED ]; then
  for i in `cat $REMOVED`
  do
    echo $i >> $DIFFS
    echo >> $DIFFS
    echo "  Removed." >> $DIFFS
    echo >> $DIFFS
  done
fi
if [ -s $UNKNOWN ]; then
  for i in `cat $UNKNOWN`
  do
    echo $i >> $DIFFS
    echo >> $DIFFS
    echo "  Unknown file." >> $DIFFS
    echo >> $DIFFS
  done
fi


# Assemble the entire file
# ========================

if [ ! -s $DIFFS ]; then
  echo 'Nothing to check in'
  rm -f $MODIFIED $DIFFS $ADDED $REMOVED $COMMENTS
  exit 0
fi


# Create a file containing the names of modified or added files

cat $MODIFIED $ADDED | sort > $INPUT


# Create the comments file, to be edited

rm -f $COMMENTS

# See if 'input' directives are in order

grep "\.gs" $INPUT >> /dev/null
if [ $? -eq 0 ]; then
  echo "
======== Filein script ========
" >> $COMMENTS

  for i in `cat $INPUT`
  do
    echo "input \$GSIMAGEDIR/$i" >> $COMMENTS
  done
fi


echo "

--------
" >> $COMMENTS
cat $DIFFS >> $COMMENTS

rm -f $MODIFIED $DIFFS $ADDED $REMOVED $INPUT

date >> $UPDATELOG
echo "File  $COMMENTS   ready for editing."
