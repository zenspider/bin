#!/usr/bin/perl -w

use strict;
use File::Find;
use Getopt::Long;

my @check = ();
#my $keywords = '(?<!SUF|PRE)FIX|HACK|TODO|(?<!P|O)DOC(?!UMENT|TYPE|_INSTALL)|REFACTOR';
my $keywords = '\b(FIX|HACK|TODO|DOC|REFACTOR)\b';
my %hit = ();
my %word = ();
my $total = 0;
my $html = 0;

&GetOptions(
	    html => \$html,
	   );

&find(\&wanted, '.');
&check;
&report;
exit;

sub wanted {
  my ($dev,$ino,$mode,$nlink,$uid,$gid) = lstat($_);

  if (-f _ && $_ !~ m/\.pyc$|\.o$|~$/) {
    return if -B _;
    push @check, $File::Find::name;
  } else {
    $File::Find::prune = 1 
      if $File::Find::name =~ m/CVS|blib/;
  }
}

sub check {

  print STDERR "Found ", scalar @check, " files. Scanning...\n";

  foreach my $file (@check) {
    open IN, $file || die "Couldn't open file '$file': $!";
    my $line = 0;
    while (<IN>) {
      $line++;

      if (m/($keywords)/o) {
	my $key = $1;
	s/^\s+//;
	s/\s+$//;
	push @{$hit{$file}}, sprintf("%4d: %s", $line, $_);
	$word{$key}++;
	$total++;
      }
    }
    close IN;
    print STDERR ".";
  }
  print STDERR "done\n\n";

  return %hit;
}

sub report {

  my $summary = &summary;

  print "<PRE>"
    if $html;

  print $summary;

  print "Detail:\n\n";
  foreach my $file (sort {scalar @{$hit{$b}} <=> scalar @{$hit{$a}}} keys %hit) {
    print "${file}::\n\n";
    foreach my $line (@{$hit{$file}}) {

      if ($html) {
	$line =~ s|&|&amp;|g;
	$line =~ s|<|&lt;|g;
	$line =~ s|>|&gt;|g;
	$line =~ s|($keywords)|<B>$1</B>|og;
      }

      print $line, "\n";
    }
    print "\n\n";
  }

  print $summary;

  print "</PRE>\n"
    if $html;
}

sub summary {

  my $summary = '';
  my $checkcount = scalar @check;
  my $hitcount = scalar keys %hit;

  $summary .= "Summary:\n\n";
  $summary .= sprintf "  Number of files checked: %4d\n", $checkcount;
  $summary .= sprintf "  Number of files marked : %4d (%4.2f%%)\n", $hitcount, ($hitcount / $checkcount * 100);
  $summary .= sprintf "  Number of tags found   : %4d\n", $total;

  if ($hitcount > 0) {
    $summary .= sprintf "  Average tags per file  : %6.1f\n", ($total / $hitcount);
  } else {
    $summary .= sprintf "  Average tags per file  : N/A\n";
  }

  $summary .= "\n";
  $summary .= "Occurances: \n";
  foreach my $word (sort {$word{$b} <=> $word{$a}} keys %word) {
    $summary .= sprintf "%4d: %s\n", $word{$word}, $word;
  }
  $summary .= "\n";

  return $summary;
}
