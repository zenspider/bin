#!/usr/bin/perl -w

use strict;

package ParseDir;

$ParseDir::version = "1.00";
$ParseDir::fullpath = 0;

#example usage:
#
#my($dir) = &ParseDir::parse("Some:Path", 4);
#&ParseDir::print($dir);

sub parse {
  my($base, $maxdepth) = @_;
  my($verbose) = 0;
  my($result) = {};
  my(@filenames);
  
  $maxdepth = -1 if ! defined $maxdepth;
  
  return $result unless $maxdepth;
  
  print "{\n" if $verbose;
  
  opendir(DIR, $base) || die "Can't open directory \'$base\'";
  @filenames = readdir(DIR);
  closedir(DIR);
  
  my($file);
  foreach $file (@filenames) {
    my($target) = "$base:$file";
    my($data) = { "name" => $file };
    
    $data->{"path"} = "$base:$file" if $ParseDir::fullpath;
    
    if (-d $target) {
      print "$file: " if $verbose;
      $data->{"subs"} = &ParseDir::parse($target,
					 $maxdepth > 0 ? $maxdepth - 1 : -1);
    } else {
      print "$file\n" if $verbose;
    }
    $result->{"$file"} = $data;
  }
  
  print "}\n" if $verbose;
  
  return $result;
}

sub print {
  my($hash, $depth) = @_;
  
  if ( ref($hash) ne "HASH" ) {
    die "\$hash is not a hash (" . ref($hash) . ", $hash)";
  }
  
  $depth = 1 if ! $depth;
  return unless $depth;
  
  print("{\n");
  
  my($file);
  
  foreach $file (sort keys(%{$hash})) {
    my($data) = $hash->{$file};
    
    if ( ref($data) ne "HASH" ) {
      die "\$data is not a hash (" . ref($data) . ", $data)";
    }
    
    my($subs) = $data->{"subs"};
    if (ref($subs)) {
      print("  " x $depth . "$file: ");
      &ParseDir::print($subs, $depth+1);
    } else {
      print("  " x $depth . "$file\n");
    }
  }
  print "  " x ($depth - 1) . "}\n";
}

1;
