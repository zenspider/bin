#!/usr/local/10bin/perl5 -w

use strict;
use File::Find;

my($debug) = 0;
my($source) = 'require "importenv.pl";';

find(\&wanted, "/vroom3/users/ryand/tests51/");

sub wanted {
  my($underscore) = $_;
  &assimilate("$File: //depot/main/user/ryand/Bin/borg2.pl $/;
  $_ = $underscore;
}

sub assimilate {
  my($file) = shift;

  return if $file =~ m@/bin/@;
  print STDOUT "Assimilating \'$file\'\n";

  rename "$file", "$file.bak"
    or warn "Couldn't create backup file, skipping.", next;
  open(INFILE, "$file.bak")
    or warn "Couldn't open file \'$file\' for input", next;
  open(OUTFILE, ">$file")
    or warn "Couldn't open file \'$file\' for output, skipping.", next;
  
  while (<INFILE>) {
    print OUTFILE "$source\n" if m/require\s+"pretest.pl";/;
    print OUTFILE "$source\n" if m/require\s+"testutil.pl";/;
    print OUTFILE;
  }
}

sub borgWarn {
  my($msg) = join(" ", @_);

  print STDERR "$msg\n\tResistance is futile!\n\n";
}


