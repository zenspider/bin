#!/usr/bin/bash
# skeleton - bare minimum shell for processing files

com=${0##/*/}			# save command name

usage() {

  echo "Usage: $com <PUT USAGE HERE>"
}

if [ $# -lt 1 ]; then	# check num of arguments
  usage
  exit 1
fi

while getopts "h" opt; do

  case $opt in

    h)
       usage
       exit;;

    *)
       usage
       echo "$com error: unknown option $opt"
       exit 1;;

  esac

done
shift $(($OPTIND - 1))

# Do all file processing here:
for File in $*; do		# process multiple files
  echo $File
done
