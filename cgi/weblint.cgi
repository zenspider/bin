#!/usr/local/bin/perl -w

use strict;
use CGI qw(:standard escapeHTML escape);
use CGI::Carp qw(fatalsToBrowser);
# set_message);

BEGIN {
  # Joshua's fault
  # unshift(@INC, '/opt/amazon/website/lib/QualityAssurance');
  unshift(@INC, '/usr/people/ryand/Dev/Perl');
}

use File::Find;
use File::Basename;
use HTML::Weblint;
use LWP::Simple qw(get);
use Data::Dumper;

my $title = 'Weblint Results';
my $version = $HTML::Weblint::VERSION;
my $URL   = url(-absolute=>1);
my $url;

my $data;
  
my $item;
my $file = param('file') || '';
my $key  = param('key') || '';

$| = 1;

$file = '../weblint/'
  unless ($file || $key);

$title .= " for " . basename($file)
  if -f $file;

$title =~ s/\.cache$//
  if $title;

if ($file) {
  if ( -d $file ) {
    
    &printHeader;
    &printDir;

  } elsif ( -f $file ) {

    &printHeader;

    open IN, $file || print p("Cannot open '$file': $!");
    eval "\$data = " . join('', <IN>);
    print p("Warning: $@") if $@;
    close IN;

    &processSummary();
    &processDetails();

    if ($key) {
      &printDetail;
    } else {
      &printSummary;
    }
  }	
} else {
  if ($key) {
    &checkURL;
  } else {
    print p("Not sure what to do");
  }
}
&printFooter;

sub processSummary {

  print "<TABLE>\n";
  my $key;
  foreach $key (sort {$data->{ERROR}->{$b} <=> $data->{ERROR}->{$a}}
		keys %{$data->{ERROR}}) {

    push(@{$data->{SUMMARY}}, $data->{ERROR}->{$key}, $key);
  }
  print "</TABLE>\n";
}

sub processDetails {
 
  my $key;
  my $size = scalar(keys %{ $data->{ERROR} });
  my $count = 0;

  foreach $key (keys %{ $data->{ERROR} }) {

    my $url;
    foreach $url (sort { $data->{INDEX}->{$key}{$b}
			 <=> $data->{INDEX}->{$key}{$a}}
		  keys %{$data->{INDEX}->{$key}}) {
      push(@{$data->{DETAIL}->{$key}}, $url);
    }
  }
}

sub printDir {

  print
    startform(-method=>'GET',
	      -action=>$URL),
    "Weblint:",
    textfield(-name=>'key',
	      -value=>'http://host/path',
	      -size=>50),
    "&nbsp;",
    submit("Check"),
    endform();

  print "<OL>\n";
  my %contents;
  find sub { $contents{$File::Find::name}++ }, # LEAVE SPLIT rcs killing code
		       $file;
  my $item;
  for $item (sort keys %contents) {
    my $name = basename($item);
    my $size = int((stat($item))[7] / 1024);
    $name =~ s/\.cache$//;
    print "<LI><A HREF=\"$URL?file=$item\">$name</A>&nbsp;[$size Kb]\n"
      if -f $item and $item =~ m/\.cache$/;
  }
  print "</OL>\n";
}

sub printSummary {

  my $total = 0;

  map({ $total += $_} values %{$data->{ERROR}});

  print h2('Summary'), "\n";

  my $count;
  my $desc;
  my @error = @{$data->{SUMMARY}};
  my $i = 0;

  my $top5 = 0;
  for ($i = 0; $i < 10; $i += 2) {
    $top5 += $error[$i]
      if defined $error[$i];
  }

  # Print Top X worst pages
  {
    my $max = 4;
    my $topN = 0;
    print "<TABLE SPACING=2>\n";
    $i = 0;
    foreach $url (sort {$data->{ERROR_PER_URL}->{$b}
			<=> $data->{ERROR_PER_URL}->{$a}}
		  keys %{ $data->{ERROR_PER_URL} }) {
      last if $i++ >= $max;
      my $val = &CGI::escape($url);
      my $count = $data->{ERROR_PER_URL}->{$url};
      print
	"<TR><TD ALIGN=RIGHT VALIGN=TOP>",
	"<A HREF=\"$URL?key=$val\">$count</A></TD>",
	"<TD>$url</TD></TR>\n";
      $topN += $count;
    }
    my $percent = int($topN/$total*100);
    print "<CAPTION>Top $max Worst Pages ($percent% of total)</CAPTION>\n</TABLE>\n";
  }

  print "<HR>\n";
  # Print Header
  print p("Total error count = $total<BR>\nTop five errors = ", 
	  int($top5/$total*100), "% of the total."), "\n";

  # Print Error Summary
  my $max = scalar(@error);
  $i = 0;
  print "<BR><TABLE SPACING=2>\n<CAPTION>Error Summary</CAPTION>\n";
  while ($i < $max) {
    my $count = $error[$i++];
    my $desc  = $error[$i++];

    my $val = &CGI::escape($desc);
    my $percent = int($count/$total*100);
    
    print
      "<TR><TD ALIGN=RIGHT VALIGN=TOP>",
      "<A HREF=\"$URL?file=$file&key=$val\">$count</A></TD>",
      "<TD ALIGN=RIGHT VALIGN=TOP>",($percent?"$percent%":"< 1%"),"</TD>\n";
    print "<TD>$desc</TD></TR>\n";
  }
  print "</TABLE>\n";

}

sub printDetail {
  
  my %index = %{ $data->{INDEX} };

  print h2('Errors'), "\n";
  print p("URLs matching '$key'"), "\n";
  print "<TABLE>\n";
  my $url;

  foreach $url (sort {$index{$key}{$b} <=> $index{$key}{$a}}
		keys %{$index{$key}}) {
    my $safeurl = escape($url);
    my $str = "<TR><TD ALIGN=RIGHT>$index{$key}{$url}&nbsp;</TD>"
      . "<TD><A HREF=\"$URL?key=$safeurl\">$url</A></TD></TR>\n";
    print $str;
  }
  print "</TABLE>\n";
}

sub checkURL {

  &printHeader;
  print p("Live checking url '$key'");
  
  my $html = get($key);
  my $output = ''; #$html;

  my $result = &HTML::Weblint::main( \$html,
				    '-s',
				    '-e', 'img-size,require-doctype',
				    '-d', 'img-alt,empty-container,quote-attribute-value',
				    '-x', 'Netscape',
				    '-o', \$output,
				    );

  $output =~ s/</&lt;/g;
  $output =~ s/>/&gt;/g;
  $output = "No errors"
    unless $output;

  $output =~ s/line (\d+)/line <A HREF="#$1">$1<\/A>/g;

  print "<PRE>\n$output\n</PRE>\n";

  print "<H3>Source</H3>\n";

  print "<PRE>\n";
  my $i = 1;
  foreach (split(/\n/, $html)) {
    s/</&lt;/g;
    s/>/&gt;/g;
    printf("<A NAME=\"%d\">%5d</A>: %s\n", $i, $i, $_);
    $i++;
  }
  print "</PRE>\n";
}

sub printHeader {

  my $linktitle = $title;
  $linktitle =~ s|Weblint|<A HREF="$URL">Weblint</A>|;

  print
    header(),
    start_html(-Title=>$title,
	       -author=>'ryand@amazon.com',
	       -BGCOLOR=>'white',
	       ),
    
    h1($linktitle), "\n";
}

sub printFooter {

  print
    p("<SMALL>This data was created w/ a modularized version of Weblint " .
      "v$version created by ", a({href=>"mailto:ryand\@amazon.com"}, 
				 "Ryan Davis"), ".</SMALL>"),
    end_html();
}


