#!/opt/third-party/bin/perl -w
# stupid snoc
use strict;

use CGI qw(:standard :html3 escapeHTML);
#use CGI::Carp;
use CGI::Carp qw(fatalsToBrowser);
use Date::Parse; # try to remove
use Mail::Mailer;
use Time::JulianDay;
use FileHandle;

my $green       = '00ff00';
my $green_pale  = 'ccffcc';
my $red         = 'ff0000';
my $red_pale    = 'ffcccc';
my $yellow      = 'ffff00';
my $yellow_pale = 'ffffcc';

my $title = 'Project Algometer';
my $subtitle = 'Version 2.4.2';
my $action = param('action') || 'tasklist';
my $debug = param('debug');
my $datafile = param('file') || 'projects';
my $day_delta = param('delta') || 0;
my %message;		

# path and name of this program on your web server
my $URL=url(-absolute=>1) . "?file=$datafile";

$debug = 1 unless defined($debug);
my $today = local_julian_day(time) + $day_delta;
my $soon = $today + 7;

print
  header(),
  start_html(-Title=>"$title: $subtitle",
	     -author=>'zss@ZenSpider.com',
	     -dtd=>'-//W3C//DTD HTML 3.2//EN',
	     -Meta=>{'keywords'=>'Zen Spider Software, Downloads, Form',
		     'copyright'=>'(C) 1998 Zen Spider Software and Ryan Davis'},
	     -BGCOLOR=>'white',
	    ),
  h1($title),
  "<SMALL>$subtitle</SMALL>",
  p("<STRONG>Algometer</STRONG> n : device for measuring pain caused by pressure.");

&algometer();

print
  end_html;

######################################################################
# Routines:

sub algometer {

  my $items;

  if ($action ne 'help') {
    if (-f $datafile) {
      $items = &processFile($datafile);
    } else {
      $action = 'help';
    }
  }

  if ($action eq 'tasklist') {
    &tasklist(&filterDone($items));
  } elsif ($action eq 'calendar') {
    &calendar(&filterDone($items));
  } elsif ($action eq 'calendarreview') {
    &calendar($items);
  } elsif ($action eq 'review') {
    &review($items);
  } elsif ($action eq 'help') {
    &help();
  }
}

sub tasklist {

  my $items = shift;
  my $dlevel = 1;
  my ($lvl_t, $red_t, $yel_t, $grn_t, $tot_t);

  &modeline('Task List');

  my %count;
  my $item;
  foreach $item (@{$items}) {

    my $date_j = $item->{DATE_J};
    if ($date_j lt $today) {
      $count{DATE_RED}++;
    } elsif ($date_j lt $soon) {
      $count{DATE_YELLOW}++;
    } else {
      $count{DATE_GREEN}++;
    }

    my $delta = $item->{DELTA};
    if ($delta > 15) {
      $count{PERCENT_RED}++;
    } elsif ($delta > 5) {
      $count{PERCENT_YELLOW}++;
    } else {
      $count{PERCENT_GREEN}++;
    }

  }

  my $percent_count = &red($count{PERCENT_RED} || "0"). " / ".
    &yellow($count{PERCENT_YELLOW} || "0"). " / ".
      &green($count{PERCENT_GREEN} || "0");
  
  my $date_count = &red($count{DATE_RED} || "0"). " / ".
    &yellow($count{DATE_YELLOW} || "0"). " / ".
      &green($count{DATE_GREEN} || "0");
  
  print
    "</TABLE>",
    "<TABLE SPACING=2>\n",
    Tr(
       "\t", th('Pri'), "\n",
       "\t", th('Due'), "\n",
       "\t", th('Done'), "\n",
       "\t", th('Description'), "\n",
      ), "\n";

  my @items = grep {$_->{PERCENT} != 100} @{ $items };
  foreach $item (sort prioritySort @items) {

    print Tr(
	     "\t", td($item->{PRIORITY}), "\n",
	     "\t", td( {align=>"right"}, $item->{DATE_TEXT}), "\n",
	     "\t", td( {align=>"right"}, $item->{PERCENT_TEXT}), "\n",
	     "\t", td($item->{DESC}), "\n",
	    ), "\n";
  }

  print Tr(
	   "\t", td('&nbsp;'), "\n",
	   "\t", td( {align=>"right"}, $date_count), "\n",
	   "\t", td( {align=>"right"}, $percent_count), "\n",
	   "\t", td('<STRONG>Totals</STRONG>'), "\n",
	  ), "\n";

  print "</TABLE>\n";

  print "<A HREF=\"$URL\">\&nbsp;</A>\n";
  print "<A HREF=\"$URL&delta=1\">\&nbsp;</A>\n";
  print "<A HREF=\"$URL&delta=2\">\&nbsp;</A>\n";
  print "<A HREF=\"$URL&delta=3\">\&nbsp;</A>\n";
  print "<A HREF=\"$URL&delta=4\">\&nbsp;</A>\n";
  print "<A HREF=\"$URL&delta=5\">\&nbsp;</A>\n";
  print "<A HREF=\"$URL&delta=6\">\&nbsp;</A>\n";
  print "<A HREF=\"$URL&delta=7\">\&nbsp;</A>\n";

}

sub calendar {

  my $today = local_julian_day(time);
  my $items = shift || die "Need \$items for calendar data";
  my $j = shift || param('day') || $today;

  &modeline('Calendar' . ($action eq 'calendarreview' ? ' Review' : ''));

  my($year,$month,$day,$jstart,$jend,$jtoday,$cols,$i);

  # the text used for the names of the months
  my @monthnames=("January","February","March","April",
		  "May","June","July","August","September",
		  "October","November","December");

  # array for the days of the week. 
  my @daynames=("Sun","Mon","Tue","Wed","Thu","Fri","Sat");

  # check for a valid starting date
  $j = local_julian_day(time) unless $j > 0;
  # convert the julian date
  ($year,$month,$day)=inverse_julian_day($j);
  # find the julian start and end values for this month
  $jstart=julian_day($year,$month,1);
  $jend=julian_day($year,$month+1,0);
  $jtoday=local_julian_day(time);
  
  #  links to other months
  print "<a href=\"$URL&action=$action&day=".julian_day($year,$month-1,1)."\">Last Month</a> | ";
  print "<a href=\"$URL&action=$action&\">This Month</a> | ";
  print "<a href=\"$URL&action=$action&day=".julian_day($year,$month+1,1)."\">Next Month</a>\n";
  
  # heading for this month's calendar
  print "<h2 align=center>$monthnames[$month-1] $year</h2>\n";
  
  # main calendar table
  print "<table width=100% border=0 cellpadding=0>\n";
  
  # top row for days of the week
  print "<tr bgcolor=#cccccc align=center>";
  for $i (0..6) {
    print "<td width=14%>$daynames[$i]</td>";
  }
  print "</tr>\n";
  
  # figure out which day to start with...
  $j = $jstart - ($jstart+1)%7;
  $day = (inverse_julian_day($j))[2];

  # display the body of the calendar
  #   $j      - current julian date
  #   $day    - current day of the month (1..31)
  #   $jstart - julian date for first day of this month 
  #   $jend   - julian date for last day of this month 
  while($j <= $jend) {

    # next row
    print "<tr>";
    # for each day of the week...
    for $cols (0..6) {
      my ($color, $pre, $post) = ('efefef', '', '');
      my $data = join("<LI>", 
		      map {$_->{DESC}} 
		      grep($_->{DATE_J} == $j, @{$items}))
	|| '';

      $data = "<LI>$data"
	if $data;

      # figure out how to display it
      if ($j < $jstart || $j > $jend) {
	# day not in this month
	$color = "aaaaaa";
	$pre = "<small>";
	$post = "</small>";
      } elsif ($j < $jtoday) {
	# previous to today
	$color = $red_pale;
	$pre = "<i>";
	$post = "</i>";
      } elsif ($j == $jtoday) {
	# today - nothing but defaults
	$pre = "<strong>";
	$post = "</strong>";
      } elsif ($j <= $jtoday + 7) {
	# After the next seven days
	$color = $yellow_pale;
      } else {
	# after the next seven days
	$color = $green_pale;
      }
      
      print "<td VALIGN=top bgcolor=\"#$color\" width=14%>$pre$day:$post$data</td>\n";
      
      # next day...
      $day++; $j++;
      # check if it's first or last day of month
      if($j == $jstart || $j == $jend+1) {
	$day=1;
      }
    }
    print "</tr>\n";
  }
  print "</table>\n";

  return;
}

sub review {

  my $items = shift;
  my $dlevel = 1;

  &modeline('Review');

  print
    "</TABLE>",
    "<TABLE SPACING=2>\n",
    Tr(
       "\t", th('Pri'), "\n",
       "\t", th('Start'), "\n",
       "\t", th('Due'), "\n",
       "\t", th('Description'), "\n",
      ), "\n";

  my $item;
  my @items = @{ $items };
  foreach $item (sort { $a->{DATE} cmp $b->{DATE}} @items) {

    print Tr(
	     "\t", td($item->{PRIORITY}), "\n",
	     "\t", td( {align=>"right"}, $item->{START}), "\n",
	     "\t", td( {align=>"right"}, $item->{DATE}), "\n",
	     "\t", td($item->{DESC}), "\n",
	    ), "\n";
  }

  print "</TABLE>\n";
}

sub help {

  &modeline('Help');

  my $cal = `cal`;
  chomp $cal;
  $cal =~ s/^/\# /msg;

  print " <P>The algometer CGI works by parsing a simple text
  file. Lines in the text file correspond to tasks. They list, in
  order:</P>

<OL>
<LI> Priority </LI>
<LI> Percent done </LI>
<LI> Start Date </LI>
<LI> End Date </LI>
<LI> Visibility (Private or Group) </LI>
<LI> Description </LI>
</OL>

<P> Here is an example line: </P>

<PRE>3 050 1999-04-21 1999-05-06 Write a doohicky in python (1.5 hr)</PRE>

<P> This line says that this is a priority 3 task, that is 50 percent
done, started April 21st 1999, and ends May 6 1999. The rest of the
line is the description.</P>

<P> The algometer takes all non-100 percent done lines and sorts them
with a complex sort algorithm, listing the most important tasks
first. As long as you are working on the top item in the list, you
know you are working on the most important task at that time.</P>

<STRONG> The algometer now allows include lines! Here is an example:</STRONG>

<PRE>#include /home/user/file.txt blah</PRE>

<P> This line says to include the file /home/user/file.txt and use the
suffix blah to label those lines w/ the suffix \"[blah]\".</P>

<P> Here is a template task file: </P>

<table border=\"1\" bgcolor=\"#CCCCFF\">
  <tr>
    <td>
<PRE>############################################################
# PROJECTS:
#
# Format:
#
#    P Pct YYYY-MM-DD YYYY-MM-DD [PG]: Desc
#
# P = Priority
# Pct = Percent done (leading zeros)
# 1st date = start date
# 2nd date = end date
# Desc = description
#
$cal
#
############################################################
# Category 1
1 075 1999-01-01 1999-12-31 P: Private task
1 075 1999-01-01 1999-12-31 G: Group task

############################################################
# Category 2

#include /path/to/file groupStuff

############################################################
# Misc

############################################################
# Completed tasks:
4 100 1999-01-01 1999-12-31 P: Finished Example task
</PRE></td>
  </tr>
</table>

<P>Write the contents of the above table to a file (remove the
#include line if you aren't going to use it), and bookmark the
following url replacing PATH with the path to the file:</P>

<CODE>" . url() . "?file=PATH</CODE>

<P>Now keep the file up to date and you will be on top of things.</P>

";
}

##############################################################################
# Utility Routines

sub processFile {
  my $path = shift;
  my $user = shift || '';
  my $fh = new FileHandle;

  $fh->open($path)
    or ((print p("Couldn't open input file '$path': $!\n")), return []);

  my @items;
  while (defined ($_ = <$fh>)) {
    if (m/#include\s+(\S+)\s+(\S*)/) {
	my $path = $1;
	my $user = $2 || '';
	unshift (@items, @{ &processFile($path, $user) });
      } else {
	
	s/\#.*//;
	
        (print "ERROR: <PRE>'$_'</PRE>", next) unless 
          m/^\s*
            (\d+)			# Priority
             \s+			# 
             0*(\d{1,3})		# Percentage
             \s+			# 
            (\d{4}-\d\d-\d\d)		# Start Date
             \s+			# 
            (\d{4}-\d\d-\d\d)		# End Date
             \s+			# 
            ([GPgp]:\s+)?		# Private or Group
            (.+)$/x;			# Description
    
	my $priority = $1;
	my $percent = $2;
	my $startDate = $3;
	my $date = $4;
	my $private = $5;
	my $desc = $6;
	
	if ($desc =~ m,(http|ftp)://(\S+),) {
	  my $val = $2;
	  $val =~ s|/| |g;
	  $val =~ s|\?|\? |g;
	  $desc =~ s,((http|ftp)://(\S+)),<A HREF="$1">$val</A>,;
	}

	if (defined $private) {
	  $private =~ s/([GPgp]):\s*/$1/;
	  $private = (lc($private) eq 'p') ? 1 : 0;
	} else {
	  $private = 0;
	}
	
	$desc .= " [$user]"
	  if $user;
	
	my $date_j = &ParseDate($date);
	my $start_j = &ParseDate($startDate);
	my $expect;
	
	if ($date_j-$start_j) {
	  $expect = int((
			 ($today-$start_j) / ($date_j-$start_j)
			) * 100);
	} else {
	  $expect = 100;
	}
	
	my $sortCode = 0;
	my $dateText;
	
	if ($date_j lt $today) {
	  $sortCode += 6;
	  $dateText = &red($date);
	} elsif ($date_j lt $soon) {
	  $sortCode += 1;
	  $dateText = &yellow($date);
	} else {
	  $dateText = &green($date);
	}
	
	my $delta = $expect - $percent;
	my $percentText = $percent . '%'
	  . ($delta > 0 
	     ? ($expect < 100 ? " ($expect)" : " (100)")
	     : '');
	
	if ($delta > 15) {
	  $sortCode += 3;
	  $percentText = &red($percentText);
	} elsif ($delta > 5) {
	  $sortCode += 2;
	  $percentText = &yellow($percentText);
	} else {
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
			 PRIVATE => $private,
			});
      }
  }

  $fh->close;

  return \@items;
}

sub filterDone {
  my $data = shift;
  my @result = ();

  my $datum;
  foreach $datum (@{$data}) {

    unshift(@result, $datum)
      unless $datum->{PERCENT} >= 100;
  }

  return \@result;
}

sub modeline {
  my $mode = shift;

  print "<P>\nModes: ";
  print &modestr("Task List", $mode);
  print " | ";
  print &modestr("Calendar", $mode);
  print " | ";
  print &modestr("Review", $mode);
  print " | ";
  print &modestr("Calendar Review", $mode);
  print " | ";
  print &modestr("Help", $mode);
  print "</P>\n";
}

sub modestr {
  my $title = shift;
  my $current = shift;
  my $link = ($title ne $current);
  my $result = '';

  my $action = lc($title);
  $action =~ s/\s+//g;

  $result .= "<A HREF=\"$URL&action=$action\">"
    if $link;

  $result .= "$title";

  $result .= "</A>"
    if $link;

  return $result;
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
  || $a->{DESC}     cmp $b->{DESC};

}

##############################################################################
#

exit 0;
1;
