#!/usr/local/10bin/perl5 -w

use strict;

my($max, $target) = @ARGV;
my($out)  = "";
my($head) = "";
my(@body) = ();
my($tail) = "";

open(IN, $target) || die "Couldn't open file $target";

while ($_ = <IN>) {
  $head .= $_;
  last if /<DL[^>]*>/;
}

while ($_ = <IN>) {
  ($tail .= $_, last) if /<\/DL>/;
  push @body, $_;
}

while ($_ = <IN>) {
  $tail .= $_;
}

my($count) = 1;
while (@body) {
  $out = $target;
  $out =~ s/(\.[^\.]+)$/.$count$1/;
  open OUT, ">$out"
    or die "Couldn't open '$out' for output: $!";
  
  print OUT $head;
  my($max) = $max;
  while ($max-- && @body) {
    print OUT shift @body;
  }
  print OUT $tail;
  close OUT;
  $count++;
}
