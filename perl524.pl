/bin/env perl4 -pi.pl5 -w

# NOTE: This doesn't pay too much attention to context
# so it may corrupt some of your work. Be sure to diff
# against the backup.pl5 file!

next if /^\#/;

#
# strict module not available in perl 4
#

s/^use\s+strict/\#use strict/;

#
# Scoping:
#
# my(...) ==> local(...)
#

s/my\(/local\(/g;

#
# Module References:
#
# Module::varOrSub ==> Module'varOrSub
#       ::varOrSub ==>       'varOrSub
#

s/(w*)::(\w+)/$1\'$2/g;
