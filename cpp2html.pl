#!/usr/bin/perl -w

use strict;

######################################################################
#
# Filename : cpp.pl
# Author   : Ryan Davis (RWD) <mailto:zss@POBoxes.com>
#
# Purpose  : Define a simple perl script to convert .h files to .html
#          : My intent is to finally have a filter that will output
#          : "pretty" html files, meaning readable and only pertinant
#          : information. At some time I'd even like it to jump
#          : a few extra hoops for me so that I might be able to use
#          : it's output for fully cross referenced documentation.
#
# Revisions:
# 2.1.0    12/15/96 Modified to use my HTML.pl routines.
# 2.0.0    12/08/96 Complete rewrite "with a clue".
# 1.1.1    05/05/96 Added multiple file support.
# 1.1.0    05/03/96 Finally outputs html that passes WebLint.
#                   Still really ugly...
# 1.0.0    05/01/96 Birthday.
#
######################################################################

use strict;

require "HTML.pl";

my($headers);		# dictionary of header info
my($revisions);		# dictionary of revisions
my($lastKey) = '';	# last entry in headers

sub skipToCommentBlock {
  my($inputFile) = @_;
  my($result) = 0;	# result=1 if we reach comment block
  
  while (<$inputFile>) { # read until comment block starts
    next unless s|^\s*//+\s*||;
    $result=1;
    last;
  }
  return $result;
}

sub parseCommentHeader {
  my($inputFile) = @_;
  my($result) = 0;
  
  while (<$inputFile>) {	# read until at the end or interrupted
    last unless s|^\s*//\s+||; # if comment, strip it, otherwise exit.
    
    # extract the "key : value" pair
    my($key, $value, $tmp);
    if ( ($key, $value) = m/\s*([^:\s]+)\s*:\s*(.*)/ ) {
      $result=1; # successfully parsed at least 1 key:value pair.
      $::lastKey = $key;
      if ($key eq "Revisions") {
	$result = &parseRevisions($inputFile);
	last;
      }
      $::headers{$key} = $value;
    } elsif ( ($tmp) = m/\s*:(.*)/ ) {	# or extract the value and append to previous value
      next if ($tmp eq "");
      $::headers{$::lastKey} .= $tmp;
    }
  }
  
  return $result;
}

sub parseRevisions {
  my($inputFile) = @_;
  my($result) = 1;
  
  if ( $::lastKey eq "Revisions" ) {
    $result=0;
    while (<$inputFile>) {	# read until at the end or interrupted
      last unless s|^\s*//\s+||; # if comment, strip it, otherwise exit.
      
      my($ver, $date, $desc, $tmp);
      if ( ($ver, $date, $desc) =
	   
	   m|\s*(\d+\D\d+\D\d+)\s+(\d+/\d+/\d+)\s+(.*)| ) {
	$result=1;
	$::lastKey = $ver;
	$::revisions{$ver}[1] = $date;
	$::revisions{$ver}[2] = $desc;
      } elsif ( ($tmp) = m/\s*(.*)/ ) { # or extract the value and append to previous value
	next if ($tmp eq "");
	$::revisions{$::lastKey}[2] .= $tmp;
      }
    }
  }
  
  return $result;
}

sub commentBlock {
  my($result) = "";
  my($hlist) = "";
  my($rlist) = "";
  my($key) = "";
  
  foreach $key (sort keys(%::headers)) {
    next if ($key eq "Classname");
    
    $hlist .= &HTML::dictTerm(&HTML::strong($key . ":"));
    
    $hlist .= &HTML::dictDef($::headers{$key});
    delete $::headers{$key}; # clean as we go along
  }
  
  foreach $key (reverse sort keys(%::revisions)) {
    $rlist .= &HTML::dictTerm(&HTML::strong($key . ":"));
    
    $rlist .= &HTML::dictDef($::revisions{$key}[1]);
    $rlist .= &HTML::dictDef($::revisions{$key}[2]);
    delete $::revisions{$key}; # clean as we go along
  }
  
  $result = &HTML::dictionary(
			      $hlist,
			      &HTML::dictTerm(
					      &HTML::rule(),
					      &HTML::strong("Revisions:"),
					      &HTML::dictionary($rlist),
					     )
			     ) . &HTML::rule();
  
  #	print "$result\n";
  
  return $result;
}

sub remainingBody {
  
  my($inputFile) = @_;
  my($result) = "";
  
  while (<$inputFile>) {
    
    #		s|(//.*$)|&italic($1)|;
    
    $result .= $_ ;
  }
  
  return &HTML::pre($result);
}

sub processFile {
  
  my($inputFile) = @_;
  #	my($OLDFILE);
  my($INPUT);
  
  open(INPUT, "<$inputFile") or die "couldn't open $inputFile";
  
  die "File's comment header not found in $inputFile" 
    unless &skipToCommentBlock(\*INPUT);
  warn "Error parsing comment header in $inputFile" 
    unless &parseCommentHeader(\*INPUT);
  
  my($outputFile) = $inputFile;
  $outputFile =~ s/\.[ht]$/\.html/;
  #$::headers{'Classname'} . ".html";
  
  #	$OLDFILE=select;
  open(OUTFILE, ">$outputFile");
  # Make it a Netscape File (not necessary)
  &MacPerl::SetFileInfo("MOSS", "TEXT", $outputFile) if $MacPerl::version;
  #	select OUTFILE;
  
  print OUTFILE &HTML::html("Class $::headers{'Classname'}",
			    &::commentBlock,
			    &::remainingBody(\*INPUT),
			   );
  
  delete $::headers{'Classname'};
  
  close(OUTFILE);
  #	select $OLDFILE;
  
  close(INPUT);
}

sub filter {
  my($string) = @_;
  
  $string =~ s/&/\&amp\;/g;
  $string =~ s/\</\&lt\;/g;    # TODO: Need to filter < & > only whem non-HTML entities!
    $string =~ s/\>/\&gt\;/g;
  
  # Mail addresses:
  $string =~ s|(\w+)@([a-zA-Z][\w.+\-]+\.[a-zA-Z]{2,})|<a
    href="mailto:$&">$&</a>|g;
  
  return $string;
}

my($file);
foreach $file (@ARGV) {
  
  next unless ($file =~ /\.[ht]$/);
  &processFile($file);
}
