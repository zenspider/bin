#!/usr/local/10bin/perl5 -w

use strict;

unshift(@INC, "/toasters/toaster5/users/ryand/Bin");
use HTML;

my($debug) = 0;

sub formatRef {
  my($ref) = shift;

  return $ref unless ref($ref);

  return    &formatRef($ref) if ref($ref) eq "REF";
  return &formatScalar($ref) if ref($ref) eq "SCALAR";
  return  &formatArray($ref) if ref($ref) eq "ARRAY";
  return   &formatHash($ref) if ref($ref) eq "HASH";
  return   &formatCode($ref) if ref($ref) eq "CODE";

  die "I can't handle glob references" if ref($ref) eq "GLOB";
}

sub formatScalar {
  my($ref) = shift || die "formatScalar must be called with an argument";
  die "formatScalar must be passed a reference to a scalar"
    unless ref($ref) eq "SCALAR";

  return $$ref;
}

sub formatArray {
  my($ref) = shift || die "formatArray must be called with an argument";
  die "formatArray must be passed a reference to a scalar"
    unless ref($ref) eq "ARRAY";
  my(@array) = @$ref;
  my($result) = "";

  foreach $ref (@array) {
    $result .= &listItem(&formatRef($ref));
  }
  return &list($result);
}

sub formatHash {
  my($ref) = shift || die "formatHash must be called with an argument";
  die "formatHash must be passed a reference to a scalar"
    unless ref($ref) eq "HASH";
  my(%hash) = %$ref;
  my($key) = "";
  my($result) = "";

  foreach $key (sort keys %hash) {
    $result .= &dictTerm($key);
    $result .= &dictDef(&formatRef($hash{$key}));
  }
  return &dictionary($result);
}

sub formatCode {
  my($ref) = shift || die "formatCode must be called with an argument";
  die "formatCode must be passed a reference to a subroutines"
    unless ref($ref) eq "CODE";

  return &formatRef(&$ref);
}

if ($debug) {

  sub test {
    
    my($scalar) = 123;
    my(@array) = ("Abc", \$scalar);
    my(%hash);
    
    $hash{"array"} = \@array;
    $hash{"hash"} = {'Something' => 'SomethingElse', 'a' => 'b' };
    
    return \%hash;
  }
  
  my($scalar) = "Abc";
  my(@array) = ("Abc", 123);
  my(%hash);

  $hash{"Abc"} = 123;
  $hash{"def"} = 345;

  print &html(
	      "Test of $0",
	      &formatRef(\$scalar),
	      &formatRef(\@array),
	      &formatRef(\%hash),
	      &formatRef(\&test),
	     );
}

1;
