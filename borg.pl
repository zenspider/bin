#!/usr/local/10bin/perl5 -w

use strict;
use File::Find;

my($debug) = 0;
my($header) = '#!/usr/bin/perl';

find(\&wanted, "/vroom3/users/ryand/tests51");

sub wanted {
  &assimilate("$File: //depot/main/user/ryand/Bin/borg.pl $/;
}

sub assimilate {
  my($file) = shift;

  print STDERR "Assimilating \'$file\'\n";

  open(INFILE, "$file")
    or warn "Couldn't open file \'$file\' for input", next;
  
  if ($_ = <INFILE>) {
    unless (m|^$header$|o) { # match #! in header
      &borgWarn("File $file does not have proper \#\! header:\n\t$_");
      
      rename "$file", "$file.bak"
	or warn "Couldn't create backup file, skipping.", next;
      open(OUTFILE, ">$file")
	or warn "Couldn't open file \'$file\' for output, skipping.", next;

      print OUTFILE "$header\n";
      print "$_\n" unless m/^\#\!/;
      while (<INFILE>) {
	print OUTFILE;
      }
    }
  } else {
    warn "Error reading first line of $file", next;
  }
}

sub borgWarn {
  my($msg) = join(" ", @_);

  print STDERR "$msg\n\tResistance is futile!\n\n";
}


