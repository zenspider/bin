#!/usr/local/10bin/perl5 -w

use strict;

unshift(@INC, "/toasters/toaster5/users/ryand/Bin");
use HTML;
require("parsedir.pl");

# This is the source directory to document:
my($basePath) = "Envy:Source";
# This is the result file to write to:
my($outfile) = "$basePath:0_TOC.html";
# This is the maximum depth to document:
my($maxDepth) = 3;
# This is the HTML file title:
my($title) = "ZSS Source TOC";

############################################################
# You shouldn't have to modify past here:

# Turn on ParseDir's ability to store full paths w/ data
$ParseDir::fullpath = 1;
# Get the data
my($sourceDir) = &ParseDir::parse($basePath, $maxDepth);

# Get STDOUT's current filehandle
my($OLDFILE) = select;
# Open $outfile
open(OUTFILE, ">$outfile");
# Make it a Netscape File (not necessary)
&MacPerl'SetFileInfo("MOSS", "TEXT", $outfile);
# Redirect STDOUT to $outfile
select OUTFILE;

# run dirToHTML and pass on to HTML body
print HTML::html($title, &dirToHTML($sourceDir));

# Close $outfile
close(OUTFILE);
# Restore STDOUT to previous filehandle
select $OLDFILE;

sub dirToHTML {
	my($hash, $depth) = @_;
	my($result) = "";

	if ( ref($hash) ne "HASH" ) {
		die "\$hash is not a hash (" . ref($hash) . ", $hash)";
	}

	$depth = 1 if ! $depth;
	return $result unless $depth;

	my($file);
	foreach $file (sort keys(%{$hash})) {
		my($data) = $hash->{$file};

		if ( ref($data) ne "HASH" ) {
			die "\$data is not a hash (" . ref($data) . ", $data)";
		}

		my($path) = $data->{"path"};
		my($url) = &HTML::url("file:///", $path, "$file");


		my($subs) = $data->{"subs"};
		if (ref($subs)) {

			$result .= &HTML::dictTerm("<BR>\n$url:");

			my($dir) = $data->{"path"};
			my($readmeFile) = "$dir:include.html";
			my($readmeText) = "";

			if (-f $readmeFile) {
				open(README, $readmeFile) || die "Error
opening $readmeFile";
				while (<README>) {
					chop;
					$readmeText .= $_;
				}
				close(README);
				$result .= &HTML::dictDef($readmeText,
"<BR><HR>");
				delete $subs->{"include.html"};
			}

			$result .= &dirToHTML($subs, $depth+1);
		} else {
			$result .= &HTML::dictTerm($url);
		}
	}

	return $result ? &HTML::dictionary($result) : "";

}
