#!/usr/local/10bin/perl5 -pi.bak -w

use strict;

print "
    ############################################################
    #
    # sub $1
    #
    #	returns: (type) description
    #
    ############################################################

" if m/^sub\s+(\w+)\s+{/;
