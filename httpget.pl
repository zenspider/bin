#!/opt/third-party/bin/perl -w

require 5.002;
use strict;
use sigtrap;
use Socket;

my ($arg) = shift || "";
if ($arg =~ m|(http://)?([^:/]+)(:(\d+))?(/.*)?|) {
  print "arg = $arg\n";
  my $remote = $2 || "rock";
  my $port   = $4 || 80;
  my $page   = $5 || "/";
  print &getPage( $remote, $port, $page), "\n";
} else {
  print &getPage( "rock", 8080, "/~ryand" ), "\n";
}

sub getPage {
    
    my($remote, $port, $page) = @_;
    die "No hostname specified!\n" unless $remote;
    die "No port specified!\n" unless $port;
    die "No page specified!\n" unless $page;
    
    print "addr = $remote\n";
    print "port = $port\n";
    print "page = $page\n";

    if ($port =~ /\D/) {
      $port = getservbyname($port, 'tcp');
    }
    die "No port" unless $port;

    my $iaddr = inet_aton($remote);
    my $paddr = sockaddr_in($port, $iaddr);
    my $proto = getprotobyname('tcp');

    #MAKE the socket filehandle.
    socket(SOCK, PF_INET, SOCK_STREAM, $proto)
      or die "socket: $!: $proto";

    #Call up the server.
    connect(SOCK, $paddr)
      or die "connect: $!: Can't connect to '$paddr'\n";
    
    #Set socket to be command buffered.
    select(SOCK); $| =1; select(STDOUT);
    
    my($request) = "GET $page HTTP/1.0\r\n\r\n";
    print SOCK $request;
    
    my($old) = $/;
    # Turns on whole file streaming in <> operator
    undef $/;
    # Read in entire file
    my $result = <SOCK>;
    # Set things back to normal (in case we use this function elsewhere)
    $/ = $old;

    close(SOCK);

    return $result;
}
