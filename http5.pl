#!/usr/bin/perl4

local($bin) = "/home/ryand/public_html";
unshift(@INC, "/home/ryand/Bin");

require("HTML.pl");

chdir($bin);
$ENV{'QUERY_STRING'} =~ s/(\%(..))/pack('c', hex("$2"))/eg;
local(@args) = grep(s/^\S+=(\S+)$/$1/, split(/\&/, $ENV{'QUERY_STRING'}));

@args = @ARGV unless @args;
local($script) = "";
$script = shift(@args);
local($target) = "";
$target = "$bin/$script";

if (-f $target) {
    
   if  (! open(RESULT, "/usr/bin/perl5 $target " . join(" ", @args) . "|")) {
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
    $::contentType = "text/html";
    print &html("Error, script not found",
		&p("The script you requested was not found: $target"),
		&p("args = ", join(", ", @args)),
	       );
}
