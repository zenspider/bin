#!/usr/local/10bin/perl5 -pi.bak

# netldiNN has changed to jnetldi10
s|netldi50|jnetldi10|g;

# Change error file versions
s|english5[01]\.err|engish10.err|g;

# Change entries in hidden/product lib dirs
s|gcilnk50|gcilnk10|g;
s|gcirpc50|gcirpc10|g;
s|gcitstlnk5[01]|gcitstlnk10|g;
