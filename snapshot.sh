#! /usr/bin/bash

#
#  This script will capture a picture and convert it to jpeg w/ a unique name
#

set -u
#set -xv

DATE_VAR=$(date +%Y%m%d%H%M%S)
ROOT=~/public_html/security
FILE_NAME=$ROOT/security
NEW_FILENAME=$FILE_NAME.$DATE_VAR
JPG_NAME=$NEW_FILENAME.jpg

# use vidtomem to grab a single fram from camera, 
# and store that to disk
vidtomem -f $FILE_NAME -z 1/2 &> /dev/null

# process the incoming file, adjusting contrast with imgexp
imgexp $FILE_NAME-00000.rgb $NEW_FILENAME 0 120
rm -f $FILE_NAME-00000.rgb

# convert image into a jpg file... perform some adjustments, if
# possilbe, to contrast and color.
imgcopy -h $NEW_FILENAME $JPG_NAME &> /dev/null

rm $NEW_FILENAME > /dev/null 2>&1
rm -f $ROOT/../security.jpg
ln $JPG_NAME $ROOT/../security.jpg
