/bin/env perl5 -pi.pl4 -w

use strict;

# NOTE: This doesn't pay too much attention to context
# so it may corrupt some of your work. Be sure to diff
# against the backup.pl4 file!

next if /^\#/;

#
# strict module not available in perl 4
#

s/^\#use\s+strict/use strict/;

#
# Scoping:
#
# local(...) ==> my(...)
#

s/local\(/my\(/g;

#
# Module References:
#
# Module'varOrSub ==> Module::varOrSub
#       'varOrSub ==>       ::varOrSub
#

s/(w*)\'(\w+)/$1::$2/g;
