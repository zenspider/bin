#!/usr/bin/perl -w

use strict;
use File::Find;
use Getopt::Long;

$| = 1;

# TODO: figure out how to pipe through more ONLY if we are interactive
sub I_am_interactive {
    return -t STDIN && -t STDOUT;
}

my @check = ();
#my $keywords = '(?<!SUF|PRE)F IX|H ACK|T ODO|(?<!P|O)D OC(?!UMENT|TYPE|_INSTALL)|RE FACTOR';
my $keywords = '\b(F IX|H ACK|T ODO|D OC|R EFACTOR|R ETIRE)\b';
my %hit = ();
my %word = ();
my $total = 0;
my $html = 0;

&GetOptions(
	    html => \$html,
	   );

@ARGV = ('.') unless @ARGV;

&find(\&wanted, @ARGV);
&check;
&report;
exit;

sub wanted {
  my ($dev,$ino,$mode,$nlink,$uid,$gid) = lstat($_);

  if (-f _ && $_ !~ m/\.pyc$|\.o$|~$/) {
    return if -B _;
    push @check, $File::Find::name;
  } else {
    if ($File: //depot/main/user/ryand/Bin/progress.pl $/ || -l _) {
      $File::Find::prune = 1;
    }
  }
}

sub check {

  print STDERR "Found ", scalar @check, " files. Scanning...\n";

  my $count = 0;
  foreach my $file (@check) {
    open IN, $file || die "Couldn't open file '$file': $!";
    my $line = 0;
    while (<IN>) {
      $line++;

      if (m/($keywords)/xo) {
	my $key = $1;
	s/^\s+//;
	s/\s+$//;
	push @{$hit{$file}}, sprintf("%4d: %s", $line, $_);
	$word{$key}++;
	$total++;
      }
    }
    close IN;
    print STDERR 'x'
      unless ++$count % 10;
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
    print "${file} (", scalar(@{$hit{$file}}), "):\n\n";
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
  $summary .= sprintf "  %-24s : %4d\n", "Number of files checked", $checkcount;
  $summary .= sprintf "  %-24s : %4d (%4.2f%%)\n", "Number of files marked", $hitcount, ($hitcount / $checkcount * 100);
  $summary .= sprintf "  %-24s : %4d\n", "Number of tags found", $total;

  if ($hitcount > 0) {
    $summary .= sprintf "  %-24s : %7.2f\n", "Tags per infected file", ($total / $hitcount);
    $summary .= sprintf "  %-24s : %7.2f\n", "Tags per all files", ($total / $checkcount);
  }

  $summary .= "\n";
  $summary .= "Occurances: \n";
  foreach my $word (sort {$word{$b} <=> $word{$a}} keys %word) {
    $summary .= sprintf "%4d: %s\n", $word{$word}, $word;
  }
  $summary .= "\n";

  return $summary;
}
