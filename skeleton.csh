#!/bin/csh
# skeleton - bare minimum shell for processing files

set com = $0			# save command name

if ($#argv < 1) then		# check num of arguments
	echo "Usage: $com:t PUT USAGE HERE"
	exit 1
endif

# Do all file processing here:
foreach File ($argv)		# process multiple files

	if ($File == "-help") then	# example of flag
		echo "PUT HELP HERE"
		shift			# remove "-help" from queue
	endif
end
