#!/usr/local/10bin/perl5 -w

use strict;

my($debug) = 1;

my($hostname, $portnumber, $uri, $header);
my($page) = &complexGet( $hostname, $portnumber, $uri );
($page, $header) = &splitHttpHeader( $page );
print $header;

exit;

sub simpleGet { 
  my($url) = @_;
  my($hostname, $portnumber, $uri) = &splitUrl( @ARGV );
  my($request) = "GET $uri HTTP/1.0\r\n\r\n";
  return &submitRequest( $hostname, $portnumber, $request );
}

sub complexGet {
  
  my($hostname, $portnumber, $uri) = &splitUrl( @ARGV );
  my($url) = @ARGV;
  my($request) = "GET $url HTTP/1.0\r\n\r\n";
  
  print "URL = $url\n" if $debug;
  return &submitRequest( $hostname, $portnumber, $request );
}

sub splitHttpHeader {
  my( $doc ) = @_;
  my( @result ) = split( "\n", $doc);
  my( $header );
  my($line);
  while( ! (($line = shift( @result )) =~ m/^\r/ ) ) {
    $header =~ s#$#$line\n#;
  }
  
  return ( join( "\n", @result ), $header );
}

sub splitUrl {
  # returns the url broken into hostname, port, and document uri.
  my($url) = @_;
  my($hostname, $portnumber, $uri);
  if ( $url =~ m#http://(\w+(\.(\w+))*)(\:(\d+))?((\/.*)*)# ) {
       $hostname = $1;
       $portnumber = $5;
       $uri = $6;
       $portnumber = 80 unless $portnumber;
       $uri = "/" unless $uri;
    } else {
      die "OOPS, no match.\n";
    }
  return ($hostname, $portnumber, $uri);
}

sub submitRequest {
  my($them, $port, $request) = @_;
  die "No port specified!\n" unless $port;
  die "No hostname specified!\n" unless $them;
  die "No request specified!\n" unless $request;
  
  print "Them = $them\nPort = $port\nRequest = $request\n" if $debug;
  
  my($AF_INET) = 2;
  my($SOCK_STREAM) = 2; # 1 for linux, aix, sunos
  my($sockaddr) = 'S n a4 x8'; 
  my($hostname, $name, $aliases, $proto, $type);
  my($len, $thisaddr, $this, $that, $thataddr);
  chop($hostname = `hostname`); 
  ($name, $aliases, $proto) = getprotobyname('tcp');
  ($name, $aliases, $port) = getservbyname($port,'tcp')
    unless $port =~ /^\d+$/;
  ($name, $aliases, $type, $len, $thisaddr) = 
    gethostbyname($hostname);
  ($name, $aliases, $type, $len, $thataddr) = gethostbyname($them);
  
  $this = pack($sockaddr, $AF_INET, 0, $thisaddr);
  $that = pack($sockaddr, $AF_INET, $port, $thataddr);
  
  #MAKE the socket filehandle.
  
  if (! socket( S, $AF_INET, $SOCK_STREAM, $proto)) {
    die $!;
  }
  
  #GIVE the socket an address.
  
  if (! bind(S, $this)) {
    die $!;
  }
  
  #Call up the server.
  
  if (! connect( S, $that)) {
    die "Failed to connect to host: $hostname.\n" . $!;
  }
  
  #Set socket to be command buffered.
  
  select(S); $| =1; select(STDOUT);
  
  print S $request;
  
  my( $result ) = join( "", <S> );
  close(S);
  return $result;
}
