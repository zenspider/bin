#!/usr/bin/perl -w

use strict;
use CGI qw(:standard escapeHTML);
use CGI::Carp qw(fatalsToBrowser set_message);
use Mail::Mailer;
use Data::Dumper;
use Time::JulianDay;

my $q = new CGI;
my $title = 'Project Algometer';
my $action = param('action') || 'step1.1';
my $debug = param('debug');
my %message;		

$debug = 1 unless defined($debug);
my $today = local_julian_day(time);
my $soon = $today + 7;

print
  header(),
  start_html(-Title=>$title,
	     -author=>'zss@ZenSpider.com',
	     -Meta=>{'keywords'=>'Zen Spider Software, Downloads, Form',
		     'copyright'=>'(C) 1998 Zen Spider Software and Ryan Davis'},
	     -BGCOLOR=>'white',
	    ),
  h1($title);

&algometer();

print
  end_html;

######################################################################
# Routines:

sub algometer {

  my $items = &processFile();
  &printResults($items);
}

my %count;
sub processFile {

  open INPUT, "../projects"
    or (print "Couldn't open input file\n", return);

  my @items;
  while (defined($_ = <INPUT>)) {

    s/\#.*//;

    (print "ERROR: <PRE>'$_'</PRE>", next) unless 
      m/^\s*(\d+)\s+0*(\d{1,3})\s+(\d{4}-\d\d-\d\d)\s+(\d{4}-\d\d-\d\d)\s+(.+)$/;
    
    my $priority = $1;
    my $percent = $2;
    my $startDate = $3;
    my $date = $4;
    my $desc = $5;
    my $date_j = &ParseDate($date);
    my $start_j = &ParseDate($startDate);
    my $expect = int((
		      ($today-$start_j) / ($date_j-$start_j)
		     ) * 100);
    my $sortCode = 0;
			
    next if $percent == 100;

    my $dateText;
    if ($date_j lt $today) {
      unshift(@{ $count{DATE_RED} }, $priority);
      $sortCode += 6;
      $dateText = &red($date);
    } elsif ($date_j lt $soon) {
      unshift(@{ $count{DATE_YELLOW} }, $priority);
      $sortCode += 2;
      $dateText = &yellow($date);
    } else {
      unshift(@{ $count{DATE_GREEN} }, $priority);
      $dateText = &green($date);
    }

    my $delta = $expect - $percent;
    my $percentText = $percent;
    $percentText .= '%' . ($delta > 0 ? 
			   ($expect < 100 ? " ($expect)" : " (100)") : '');
    
    if ($delta > 15) {
      unshift(@{ $count{PERCENT_RED} }, $priority);
      $sortCode += 3;
      $percentText = &red($percentText);
    } elsif ($delta > 5) {
      unshift(@{ $count{PERCENT_YELLOW} }, $priority);
      $sortCode += 1;
      $percentText = &yellow($percentText);
    } else {
      unshift(@{ $count{PERCENT_GREEN} }, $priority);
      $percentText = &green($percentText);
    }

    unshift(@items, {
		     SORTCODE => $sortCode,
		     PRIORITY => $priority,
		     PERCENT => $percent,
		     PERCENT_TEXT => $percentText,
		     DATE => $date,
		     DATE_TEXT => $dateText,
		     DATE_J => $date_j,
		     START => $startDate,
		     START_J => $start_j,
		     DESC => $desc,
		     EXPECT => $expect,
		     DELTA => $delta,
		    });
  }
  close INPUT;

  return \@items;
}

sub printResults {

  my $items = shift;
  my $dlevel = 1;
  my ($lvl_t, $red_t, $yel_t, $grn_t, $tot_t);
  while (1) {

    my $red = scalar(grep(/$dlevel/, @{$count{DATE_RED}}));
    my $yel = scalar(grep(/$dlevel/, @{$count{DATE_YELLOW}}));
    my $grn = scalar(grep(/$dlevel/, @{$count{DATE_GREEN}}));

    last unless ($red || $yel || $grn);
    
    $lvl_t .= th($dlevel);
    $red_t .= td(&red($red));
    $yel_t .= td(&yellow($yel));
    $grn_t .= td(&green($grn));
    $tot_t .= td($red+$yel+$grn);

    $dlevel++;
  }

  $lvl_t .= th('='),
  $red_t .= td(&red(scalar(@{$count{DATE_RED}}))),
  $yel_t .= td(&yellow(scalar(@{$count{DATE_YELLOW}}))),
  $grn_t .= td(&green(scalar(@{$count{DATE_GREEN}}))),
  $tot_t .= td(scalar(@{$count{DATE_RED}})
	       + scalar(@{$count{DATE_YELLOW}})
	       + scalar(@{$count{DATE_GREEN}}));

  $lvl_t .= th('&nbsp;');
  $red_t .= td('&nbsp;');
  $yel_t .= td('&nbsp;');
  $grn_t .= td('&nbsp;');
  $tot_t .= td('&nbsp;');

  my $plevel = 1;
  while (1) {

    my $red = scalar(grep(/$plevel/, @{$count{PERCENT_RED}}));
    my $yel = scalar(grep(/$plevel/, @{$count{PERCENT_YELLOW}}));
    my $grn = scalar(grep(/$plevel/, @{$count{PERCENT_GREEN}}));

    last unless ($red || $yel || $grn);
    
    $lvl_t .= th($plevel);
    $red_t .= td(&red($red));
    $yel_t .= td(&yellow($yel));
    $grn_t .= td(&green($grn));
    $tot_t .= td($red+$yel+$grn);

    $plevel++;
  }

  $lvl_t .= th('='),
  $red_t .= td(&red(scalar(@{$count{PERCENT_RED}}))),
  $yel_t .= td(&yellow(scalar(@{$count{PERCENT_YELLOW}}))),
  $grn_t .= td(&green(scalar(@{$count{PERCENT_GREEN}}))),
  $tot_t .= td(scalar(@{$count{PERCENT_RED}})
	       + scalar(@{$count{PERCENT_YELLOW}})
	       + scalar(@{$count{PERCENT_GREEN}}));

  print 
    "<TABLE CELLPADDING=2 CELLSPACING=2>\n",
    Tr(
       th({-COLSPAN=>$dlevel-1}, 'Due'),
       td('&nbsp;'),
       th({-COLSPAN=>$plevel-1}, 'Done'),
      );

  print
    "\t", Tr($lvl_t), "\n",
    "\t", Tr($red_t), "\n",
    "\t", Tr($yel_t), "\n",
    "\t", Tr($grn_t), "\n",
    "\t", Tr($tot_t), "\n";
  
  print
    "</TABLE>",
    "<TABLE ALIGN=CENTER SPACING=2>\n",
    Tr(
       "\t", th('Pri'), "\n",
       "\t", th('Due'), "\n",
       "\t", th('Done'), "\n",
       "\t", th('Description'), "\n",
      ), "\n";

  my $item;
  foreach $item (sort prioritySort @{ $items } ) {
    next
      if $item->{PERCENT} == 100;

    print Tr(
	     "\t", td($item->{PRIORITY}), "\n",
	     "\t", td($item->{DATE_TEXT}), "\n",
	     "\t", td( {align=>"right"}, $item->{PERCENT_TEXT}), "\n",
	     "\t", td($item->{DESC}), "\n",
	    ), "\n";
  }
  print "</TABLE>\n";
}

sub ParseDate {
  my $date = shift;
  
  if ($date =~ /(\d\d\d\d)-(\d\d)-(\d\d)/) {
    return julian_day($1, $2, $3);
  } else {
    return 0;
  }
}

sub red {
  return '<FONT COLOR="#FF0000">' . join('', @_) . '</FONT>';
}

sub yellow {
  return '<FONT COLOR="#AAAA00">' . join('', @_) . '</FONT>';
}

sub green {
  return '<FONT COLOR="#00AA00">' . join('', @_) . '</FONT>';
}

sub prioritySort {

  $b->{SORTCODE}    <=> $a->{SORTCODE}
  || $a->{PRIORITY} <=> $b->{PRIORITY}
  || $a->{DATE}     cmp $b->{DATE}
  || $b->{DELTA}    <=> $a->{DELTA}
#  || $b->{PERCENT}  <=> $a->{PERCENT}
  || $a->{DESC}     <=> $b->{DESC};

}

################################################################################
exit 0;
1;
