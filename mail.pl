#!/usr/bin/perl5 -w

use strict;

use Net::SMTP;

sub sendmail ($$$);

&sendmail("ryand", "test 42", "A simple test message\noh yeah\n");

sub sendmail ($$$) {
  my ($to, $subject, $msg) = @_;

  my $smtp = Net::SMTP->new('servio');
  $smtp->mail("Corwin");
  $smtp->to($to);
  $smtp->data();
  $smtp->datasend("To: $to\n");
  $smtp->datasend("Subject: $subject\n");
  $smtp->datasend("\n");
  map($smtp->datasend("$_\n"), split('\n', $msg));
  $smtp->dataend();
  $smtp->quit;
}
  
