#!/usr/local/10bin/perl5 -w

use strict;
use File::Find;

BEGIN {
  unshift(@INC, "/home/ryand/Bin");
}

use HTML;
require "HTMLFormat.pl";

local(@ARGV) = split(/\?/, $ENV{'QUERY_STRING'}) unless @ARGV;

my $linesTitle = &bold("Number of Lines:");
my $topazTitle = &bold("Topaz Dependencies:");
my $perlTitle  = &bold("Perl Dependencies");

my(%req);
my($debug) = 0;
my($root) = shift || "";
my($sub)  = shift || "";
$root .= "/$sub" if $sub;

&find(\&wanted, $root);

# Finally, print out an HTML file:
$HTML::contentType = "text/html";
$HTML::contentType = "text/html";
print &html("Gemstone 51 Test Analysis",
	    &h1("Analysis of: ", $sub ? $sub : "Gemstone 5.1 Tests"),

	    &h2("Summary:"),
	    &summary(),
	    
	    &h2("Detail:"),
	    &formatRef(\%req),
	   );

sub wanted {
  my($underscore) = $_;

  /^.*\.(gs|opl|mts|tpz|tst)$/ && &parseTopaz("$File::Find::name");
  $_ = $underscore;
  /^.*\.pl$/ && &parsePerl("$File::Find::name");
  $_ = $underscore;
}

sub parsePerl {
  my($file) = shift;
  my($relative) = $file;
  my(@perlrequire);
  my(@topazinput);
  my($linecount) = 0;

  $relative =~ s/^$root//o;
  
  open(INFILE, "$file") || die "Couldn't open file: $file";
  while (<INFILE>) {
    $linecount++;

    next if /^\s*\#/; # skip comments
    next unless (/require/ || /\&topazinput\s*\(/);

    # Match a perl require statement.
    my($match) = /require\s+\"([^\"]+)\"\;/;
    if ($match) {
      $match =~ s|^.*/([^/]+)$|$1|;
      chomp $_ if $debug;
      print "Found: $_ Matched: $match\n" if $debug;
      push(@perlrequire, $match, );
      next;
    }

    # Match a &topazinput statement.
    my($match) = /\&topazinput\s*\(\"([^\"]+)\"/;
    if ($match) {
      chomp $_ if $debug;
      print "Found: $_ Matched: $match\n" if $debug;
      push(@topazinput, $match, );
      next;
    }
  }
  close(INFILE);
  
  $req{$relative}{$perlTitle} = \@perlrequire;
  $req{$relative}{$linesTitle} = $linecount;
  $req{$relative}{$topazTitle} = \@topazinput;
}

sub parseTopaz {
  my($file) = shift;
  my($relative) = $file;
  my(@input);
  my($linecount) = 0;

  $relative =~ s/^$root//o;
  
  open(INFILE, "$file") || die "Couldn't open file: $file";
  while (<INFILE>) {
    $linecount++;

    s/\"[^\"]*\"//g;
    next if /^!/; # skip comments
    next unless (/input/);

    # Match a perl require statement.
    my($match) = m/input\s+([a-zA-Z0-9._\$\/\\]+)/;
    if ($match) {
      chomp $_ if $debug;
      print "Found: $_ Matched: $match\n" if $debug;
      push(@input, $match, );
      next;
    }
  }
  close(INFILE);
  
  $req{$relative}{$linesTitle} = $linecount;
  $req{$relative}{$topazTitle} = \@input;
}

sub summary {

  my($result) = "";

  my($test);
  foreach $test (sort keys %req) {

    my($ref);

    # Figure out the number of perl dependencies:
    # start with an empty array reference
    $ref = [];
    # Assign $ref with the reference to array of dependencies if it exists.
    $ref = $req{$test}{$perlTitle} if (exists($req{$test}{$perlTitle}));
    # get the count of the array
    my($perldeps) = scalar(@$ref);

    # Figure out the number of perl dependencies:
    # start with an empty array reference
    $ref = [];
    # Assign $ref with the reference to array of dependencies if it exists.
    $ref = $req{$test}{$topazTitle} if (exists($req{$test}{$topazTitle}));
    # get the count of the array
    my($topazdeps) = scalar(@$ref);

    $result .= &row(
		    &cellHeader($test),
		    &cell(
			  &options('ALIGN="right"'),
			  $req{$test}{$linesTitle}
			 ),
		    &cell(
			  &options('ALIGN="right"'),
			  $perldeps ? $perldeps : ""
			 ),
		    &cell(
			  &options('ALIGN="right"'),
			  $topazdeps ? $topazdeps : ""
			 ),
		   );
  }

  return &table(
		&options('BORDER="1"'),
		&row(
		     &cellHeader("Test"),
		     &cellHeader("# Lines"),
		     &cellHeader("# Perl Dep."),
		     &cellHeader("# Topaz Dep."),
		    ),
		$result
	       )
}
