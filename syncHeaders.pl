#!/usr/local/10bin/perl5 -w

use strict;

######################################################################
#
# Filename : syncHeaders.pl
# Author   : Ryan Davis (RWD) <mailto:zss@POBoxes.com>
#
# Purpose  : Define a simple perl script to compare .h and .cp source
#          : comment headers (the first comment block in the file)
#          : to verify if they are the same in each file.
#
#	VERSION  DATE     DESCRIPTION
#	1.0.0    05/05/96 Birthday.
#
######################################################################

die "I need some files! stopped " unless @ARGV;

my(@headers) = ();
my(@input) = ();

my($filename);
foreach $filename (@ARGV) {# Only keep .h files
  next unless (-f $filename && -T $filename);
  if ($filename =~ m/\.h$/) {
    push(@headers, $filename);
  }
}

foreach $filename (@headers) {# Check for corresponding .cp file
  my($sourcefile) = $filename;     #copy the path
  $sourcefile =~ s/\.h$/\.cp/; #convert the name to a .cp
  if (-e $sourcefile && -T $sourcefile) { #test for existance
    push(@input, $filename);
    push(@input, $sourcefile);
  }
}

@headers = @input;

my($header) = "";
my($headerFile) = "";
while ($ARGV = shift(@headers)) {
  open(ARGV, $ARGV) || warn "Couldn't open $ARGV";
  while (<ARGV>) {	     # read in until first comment line
    last if $_ =~ m&^\s*//&;
  }
  my($comment) = $_;
  while (<ARGV>) {      # read in until end of comment lines
    last if $_ !~ m&^\s*//&;
    $comment .= $_;
  }
  if ($header eq "") {  #if we haven't read in both files yet
    $header = $comment;  #initialize the header string
    $headerFile = $ARGV; #remember the name
  } else {              #if we have read in both files, compare
    print "$headerFile & $ARGV:\n";
    compare($header, $comment);
    $header = "";        #and reset the header variables
    $headerFile = "";
  }
}

sub compare {
  my($h, $cp) = @_;
  $cp =~ s/\.cp/\.h/g;	# mutate the file line to compensate for diff.
  if ($h eq $cp) {
    print "...are identical.\n"
  } else {
    my(@h)  = split(/^/, $h);
    my(@cp) = split(/^/, $cp);
    my($hl, $cpl) = (0, 0);
    my($hline);
    foreach $hline (0 .. $#h) { # find the first difference
      last if ($h[$hl] ne $cp[$cpl]);
      print "= $h[$hl]"; #newline is already in text...
      $hl++; $cpl++;
    }
  }
}

__END__
  
  
