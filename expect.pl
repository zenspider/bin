#!/usr/bin/bash

PERL_DL_NONLAZY=1 /opt/third-party/bin/perl -w -I/home/ryand/Install/Expect.pm-1.07 -I/home/ryand/Install/IO-Tty-0.02/blib/arch -I/home/ryand/Install/IO-Tty-0.02/blib/lib -I/home/ryand/Install/IO-Stty-.02/blib/arch -I/home/ryand/Install/IO-Stty-.02/blib/lib -I/opt/third-party/perl/lib/alpha-dec_osf/5.00404 -I/opt/third-party/perl/lib $*
