#!/usr/bin/perl -w


use strict;
use CGI qw(:standard escapeHTML);
use CGI::Carp qw(fatalsToBrowser set_message);
use Mail::Mailer;
use Date::Manip;
use Data::Dumper;

my $q = new CGI;
my $title = 'Project Algometer';
my $action = param('action') || 'step1.1';
my $debug = param('debug');
my %message;		

$debug = 1 unless defined($debug);
my $today = &ParseDate('today');
my $soon = &DateCalc('today', '+ 7 days');


print
  header(),
  start_html(	-Title=>$title,
		-author=>'zss@ZenSpider.com',
		-Meta=>{'keywords'=>'Zen Spider Software, Downloads, Form',
			'copyright'=>'copyright 1998 Zen Spider Software and Ryan Davis'},
		-BGCOLOR=>'white',
	    ),
  h1($title);

&algometer();

print
  end_html;

######################################################################
# Routines:

sub algometer {

  open INPUT, "../projects"
    or (print "Couldn't open input file\n", return);

  my (@red, @yellow, @green);
  my ($red, $yellow, $green);

  my @items;
  while (defined($_ = <INPUT>)) {

    s/\#.*//;

    (print "ERROR: <PRE>'$_'</PRE>", next) unless 
      m/^\s*(\d+)\s+0*(\d{1,3})\s+(\d{4}-\d\d-\d\d)\s+(\d{4}-\d\d-\d\d)\s+(.+)$/;
    
    my $priority = $1;
    my $percent = $2;
    my $startDate = $3;
    my $dueDate = $4;
    my $desc = $5;

    my $dueTime = &ParseDate($dueDate);

    if ($percent != 100) {

      if ($dueTime lt $today) {
	$red[$priority]++;
	$red++;
      } elsif ($dueTime lt $soon) {
	$yellow[$priority]++;
	$yellow++;
      } else {
	$green[$priority]++;
	$green++;
      }
    }

    unshift(@items, {
		     PRIORITY => $priority,
		     PERCENT => $percent,
		     DATE => $dueDate,
		     TIME => $dueTime,
		     DESC => $desc,
		    });
  }
  close INPUT;

  print 
    "<TABLE SPACING=2>\n",
    Tr(
       th("#"),
       td(&red($red)),
       td(&yellow($yellow)),
       td(&green($green)),
       td("#"),
      );

  my $index = 1;
  while (defined    $red[$index] 
	 or defined $yellow[$index] 
	 or defined $green[$index]) {
    print
      Tr(
	 "\t", th($index), "\n",
	 "\t", td(&red($red[$index])), "\n",
	 "\t", td(&yellow($yellow[$index])), "\n",
	 "\t", td(&green($green[$index])), "\n",
	 "\t", td(
		  $red[$index] +
		  $yellow[$index] +
		  $green[$index]
		 ), "\n",
	);
    $index++;
  }

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
  foreach $item (sort { $a->{PRIORITY}   <=> $b->{PRIORITY}
			|| $a->{DATE}    cmp $b->{DATE}
			|| $b->{PERCENT} <=> $a->{PERCENT}
		      } @items) {
    next
      if $item->{PERCENT} == 100;

    print Tr(
	     "\t", td($item->{PRIORITY}), "\n",
	     "\t", td(&colorDate($item)), "\n",
	     "\t", td( {align=>"right"}, $item->{PERCENT} . '%'), "\n",
	     "\t", td($item->{DESC}), "\n",
	    ), "\n";
  }
  print "</TABLE>\n";
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

sub colorDate {
  
  my $item = shift || die "Need an item";

  my ($time, $dueDate) = ($item->{TIME}, $item->{DATE});

  if ($time lt $today) {
    return &red($dueDate);
  } elsif ($time lt $soon) {
    return &yellow($dueDate);
  } else {
    return &green($dueDate);
  }
}

################################################################################
exit 0;
1;
