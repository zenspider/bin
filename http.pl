#!/usr/local/bin/perl5 -w

use strict;

my $bin = "/home/ryand/public_html";

BEGIN {
  unshift(@INC, "/home/ryand/Bin");
}

use HTML;

chdir($bin);
my @args;
if (defined($ENV{'QUERY_STRING'})) { 
  $ENV{'QUERY_STRING'} =~ s/(\%(..))/pack('c', hex("$2"))/eg;
  @args = grep(s/^\S+=(\S+)$/$1/, split(/\&/, $ENV{'QUERY_STRING'}));
}

@args = @ARGV unless defined(@args);
my($script) = "";
$script = shift(@args);
my($target) = "";
$target = "$bin/$script";

if (-f $target) {
    
   if  (! open(RESULT, "/usr/local/bin/perl5 $target " . join(" ", @args) . "|")) {
      $'contentType = "text/html";
      print &html("Diagnostic Output", 
		  &p("Could not run = $target ", join(" ", @args))
		 );
      exit 0;
    }
    
    while (<RESULT>) {
      print;
    }
    close(RESULT);
    exit 0;
  } else {
    $'contentType = "text/html";
    print &html("Error, script not found",
		&p("The script you requested was not found: $target"),
		&p("args = ", join(", ", @args)),
	       );
}
