#!/opt/third-party/bin/perl -w

use strict;

my($pathing) = $ENV{'PATH'};
my($separator) = $ENV{'IFS'};

die "you don't have path defined?" unless $pathing;
$separator = ":", warn "\$IFS not defined, using \':\'" unless $separator;

my(@dirs) = split($separator, $pathing);

foreach (@dirs) {
  my($dir) = shift @dirs;

  ((warn "$dir is not a directory"), next) unless -d $dir;
  opendir(DIR, $dir) or warn "Couldn't open $dir for read", next;
  my(@files) = readdir(DIR);
  closedir(DIR);

  foreach (@files) {
    my($file) = "$dir/" . shift @files;
    
    if (-x $file && ! -d $file) {
      print "$file\n";
    }
  }
}
