#!/usr/bin/bash

#set -xv
set -u

pid=$$
DIR=`pwd`

# Set up default filenames for the various files

COMMENTFILE=$DIR/checkin.data		# The text created from difs
SAVECOMMENTFILE=$DIR/checkin.data.bak
CMDFILE=/tmp/cmdfile$pid
LOGFILE=/tmp/logfile$pid
ERRFILE=/tmp/errfile$pid

if [ ! -f $COMMENTFILE ]; then
  echo "Data file  $COMMENTFILE  not found"
  exit 1
fi

rm -f $LOGFILE $ERRFILE
touch $ERRFILE

cvsTool=cvs
export cvsTool

cp $COMMENTFILE $SAVECOMMENTFILE
cvscheckin.sh $CMDFILE < $COMMENTFILE >& $LOGFILE
if [ -s $CMDFILE ]; then
  cat $CMDFILE
else
  cat $LOGFILE
  echo "No command file generated, check for syntax errors in checkin.data"
  exit 1
fi

# Execute if appropriate

if [ -s $CMDFILE ]; then
  sh < $CMDFILE >& $ERRFILE
fi

if [ -s $ERRFILE ]; then
  cat $ERRFILE >> $LOGFILE
fi

# Send mail

echo "" >> $LOGFILE
echo "checkin was from: $DIR" >> $LOGFILE
echo "" >> $COMMENTFILE
echo "checkin was from: $DIR" >> $COMMENTFILE

mailx -s "Checkin Results" ryand < $LOGFILE
mailx -s "Checkin Comments" ryand < $COMMENTFILE

echo "Checkin Results"
cat $LOGFILE

rm -f $CMDFILE $LOGFILE $ERRFILE $COMMENTFILE
