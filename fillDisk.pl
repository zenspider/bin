#!/usr/bin/perl5 -w

use strict;

open(OUT, ">killme.txt") or die "Couldn't open file";

my($str) = "X" x ((1024*100)-1) . "\n";
while (1) {
  print OUT "$str";
}
