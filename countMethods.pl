#!/usr/local/10bin/perl5 -w

use strict;

while (<>) {
  next unless m/<a href=\"\#/;

  s/<a href=\".*?\">(.*?)<\/a>/$1/;
  s/<.*?>//g;
  s/^\s+//;
  print;
}
