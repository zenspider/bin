#!/usr/local/10bin/perl5 -w

use strict;

######################################################################
#
# Filename : HTML.pm
# Author : Ryan Davis (RWD) <mailto:zss@POBoxes.com>
#
# Purpose : Define a set of EASY TO USE, SIMPLE, and USEFUL
# : routines for creating WebLint compliant HTML output.
#
######################################################################

package HTML;

require Exporter;
@HTML::ISA       = qw(Exporter);
@HTML::EXPORT    = qw(
		      html	bold		big		italic
		      small	strike		subscript	superscript
		      typewriter underline	abbrev		acronym
		      author	cite		del		dfn
		      emphasis	insert		keyboard	lang
		      person	quote		sample		strong
		      variable	address		blockquote	code
		      center	pre		h1		h2
		      h3	h4		h5		h6
		      h7	image		anchor		dir
		      menu	listHeader	list		orderedList
		      listItem	dictionary	dictTerm	dictDef
		      br	division	p		rule
		      comment	table		row		cell
		      cellHeader caption	url		options
		      dl	dd		dt
		     );
@HTML::EXPORT_OK = qw(
		      pair	optPair		tag		endTag
		      optTag	getOptions	nonOptions
		     );


$HTML::version = "2.00";
$HTML::author = "Ryan Davis";
$HTML::authorEmail = "zss\@POBoxes.com";
$HTML::contentType = ""; # Change to mime type for CGI Stuffs
$HTML::bgcolor = "#FFFFFF";

################################################################
# Document Structure

############################################################
#
# sub html
#
# title: (string) title of the document.
# options: (string) options for HTML tag, if any.
#
# returns: (string) full html document.
#
############################################################

sub html {
  
  my($title) = shift;
  
  $title = "Untitled" if ! $title;
  
  # FIX/NOTE: All the "\n" elements below are to be considered a KLUDGE!
  # There should be logic in the system to know which tags may
  # automatically embed newlines and which shouldn't (in order to
  # cleanly pass WebLint w/ all flags on, that is...)
  
  return ((($HTML::contentType) ? "Content-type: $HTML::contentType\n\n" : "")
	  . &optTag("!DOCTYPE",
		    &options("HTML PUBLIC \"-//W3C//DTD HTML 3.2//EN\"")
		   )
	  . "\n"
	  . &optPair("HTML",
		     "\n",
		     &pair("HEAD",
			   &optTag("LINK",
				   &options("REV=MADE HREF=\"mailto:$HTML::authorEmail\"")
				  ),
			   "\n",
			   &pair("TITLE", $title),
			  ),
		     &body(@_),
		    )
	 );
  
}

sub body {
  return &optPair("BODY",
	       &options("BGCOLOR=\"$HTML::bgcolor\""),
	       "\n",
	       join('', @_), # MEAT
	       "\n",
	       &rule,
	       &comment("Beginning of Footer:"),
	       "\n\n",
	       &p("\n", &address(&anchor(&options("HREF=" . &url("mailto:", $HTML::authorEmail,),),$HTML::author,),), ),
	       "\n",
	       &p("\n", &small("Automatically generated on ", scalar(localtime), " using HTML.pm v. $HTML::version by: ", &anchor(&options("HREF=" . &url("\"mailto:zss\@POBoxes.com\"")), "Ryan Davis" ), ),
		  ),
	       "\n",
	       );
}

################################################################
# Emphasis and Fonts
#
# All Emphasis and Font subroutines take any number of scalar
# values as it's input, and produce a string in the form of:
# "<TAG>@_</TAG>

# Physical Styles:

sub bold {
  return &pair("B", @_);
  
}
sub big {
  return &pair("BIG", @_);
}
sub italic {
  return &pair("I", @_);
}
sub small {
  return &pair("SMALL", @_);
}
sub strike {
  return &pair("S", @_);
}
sub subscript {
  return &pair("SUB", @_);
}
sub superscript {
  return &pair("SUP", @_);
}
sub typewriter {
  return &pair("T", @_);
}
sub underline {
  return &pair("TT", @_);
}

# Logical Styles:

sub abbrev {
  return &pair("ABBREV", @_);
}
sub acronym {
  return &pair("ACRONYM", @_);
}
sub author {
  return &pair("AU", @_);
}
sub cite {
  return &pair("CITE", @_);
}
sub del {
  return &pair("DEL", @_);
}
sub dfn {
  return &pair("DFN", @_);
}
sub emphasis {
  return &pair("EM", @_);
}
sub insert {
  return &pair("INS", @_);
}
sub keyboard {
  return &pair("KEY", @_);
}
sub lang {
  return &pair("LANG", @_);
}
sub person {
  return &pair("PERSON", @_);
}
sub quote {
  return &pair("Q", @_);
}
sub sample {
  return &pair("SAMP", @_);
}
sub strong {
  return &pair("STRONG", @_);
}
sub variable {
  return &pair("VAR", @_);
}

################################################################
# Text Offsets

sub address {
  return &pair("ADDRESS", @_);
}
sub blockquote {
  return &pair("BLOCKQUOTE", @_);
}
sub code {
  return &pair("CODE", @_);
}

sub center {
  return &p(&options('ALIGN="CENTER"'), @_);
}

sub pre {
  return &optPair("PRE", @_);
}

################################################################
# Headers

sub h1 {
  return &optPair("H1", @_);
}
sub h2 {
  return &optPair("H2", @_);
}
sub h3 {
  return &optPair("H3", @_);
}
sub h4 {
  return &optPair("H4", @_);
}
sub h5 {
  return &optPair("H5", @_);
}
sub h6 {
  return &optPair("H6", @_);
}
sub h7 {
  return &optPair("H7", @_);
}

################################################################
# Images

############################################################
#
# sub image
#
# url: result from &url pointing to image
# alt: string representing image's alt. description
# @_ : more options
#
# returns: string representing HTML image tag.
#
############################################################

sub image {
  my($url) = shift;
  my($alt) = shift;
  
  return &optTag("IMG",
		 &options(
			  "SRC=\"$url\"",
			  "ALT=\"$alt\"",
			  &options(@_)
			 ),
		 @_
		);
}

################################################################
# Anchors

sub anchor {
  return &optPair("A", @_);
}

################################################################
# Lists

sub dir {
  return &optPair("DIR", @_);
}
sub menu {
  return &optPair("MENU", @_);
}
sub listHeader {
  return &optPair("HL", @_);
}
sub list {
  return &optPair("UL", @_);
}
sub orderedList {
  return &optPair("OL", @_);
}
sub listItem {
  return &optPair("LI", @_);
}
sub dl {
  return &dictionary(@_);
}
sub dictionary {
  return &optPair("DL", @_);
}
sub dt {
  return &dictTerm(@_);
}
sub dictTerm {
  return &optPair("DT", @_);
}
sub dd {
  return &dictDef(@_);
}
sub dictDef {
  return &optPair("DD", @_);
}

################################################################
# Separators

sub br {
  return &pair("BR", @_);
}
sub division {
  return &optPair("DIV", @_);
}
sub p {
  return &optPair("P", @_);
}
sub rule {
  return &optTag("HR", @_);
}

################################################################
# Comments

sub comment {
  return join('', "<!--", @_, "-->");
}

################################################################
# Forms
#
# I have no plans to do forms at this time.

################################################################
# CGI
#
# I have no plans to do CGI at this time,
# however, the html sub does start with the
# "Content-type: text/html" tag.

################################################################
# Tables and Figures

sub table {
  return &optPair("TABLE", @_);
}
sub row {
  return &optPair("TR", @_);
}
sub cell {
  return &optPair("TD", @_);
}
sub cellHeader {
  return &optPair("TH", @_);
}
sub caption {
  return &optPair("CAPTION", @_);
}

################################################################
# URLS

# TODO: add url validation

sub url {
  return join('', @_);
}

################################################################
# Special Characters

# TODO: iso8859 2 way filter

################################################################
# Miscellaneous Subroutines

############################################################
#
# sub options [public]
#
# @_: (scalars) data to embed as options in HTML tag
#
# Example:
#
# &dictionary(&options("COMPACT"), ... );
#
# returns: private string to be decoded internally.
#
############################################################

sub options {
  return "<!--options" . join(" ", @_, "\cE") . "-->";
}

############################################################
#
# sub pair [private]
#
# tag: (string) HTML tag for pair
# @_: (scalars) rest of data to embed in pair
#
# returns: (string) form of "<TAG> @_ </TAG>"
#
############################################################

sub pair {
  my($tag) = shift;
  
  return &tag($tag) . join('', @_) . &endTag($tag);
}

############################################################
#
# sub optPair [private]
#
# tag: (string) HTML tag for pair
# options: (string) options to embed in tag
# @_: (scalars) rest of data to embed in pair
#
# returns: (string) form of "<TAG OPT> @_ </TAG>"
#
############################################################

sub optPair {
  my($tag) = shift;
  return &optTag($tag, @_) . join('', &nonOptions(@_)) . &endTag($tag);
}

############################################################
#
# sub tag [private]
#
# tag: (string) HTML tag to create
#
# returns: (string) tag in form of "<TAG>"
#
############################################################

sub tag {
  my($tag) = shift;
  
  return "<$tag>\n";
}

############################################################
#
# sub endTag [private]
#
# tag: (string) HTML end-tag to create
#
# returns: (string) tag in form of "</TAG>"
#
############################################################

sub endTag {
  my($tag) = shift;
  
  return "</$tag>\n";
}

############################################################
#
# sub optTag [private]
#
# tag: (string) HTML tag to create
# options: (string) options to embed in tag
#
# returns: (string) tag in form of "<TAG OPT>"
#
############################################################

sub optTag {
  my($tag) = shift;
  my(@options) = &getOptions(@_);
  
  return "<$tag" . (@options ? " " . join(" ", @options) : "") . ">";
}


############################################################
#
# sub getOptions [private]
#
# returns: (array) array of options (w/o option tags)
#
############################################################

sub getOptions {
  my(@copy) = @_;
  
  #return grep (s/^<!--options([^\cE]*)\cE-->$/$1/, @copy );
  return grep (s/<!--options(.*)-->/$1/, @copy );
}

############################################################
#
# sub nonOptions [private]
#
# returns: (array) array w/o options
#
############################################################

sub nonOptions {
  my(@copy) = @_;
  
  #([^\cE]*)\cE
  return grep (!m/<!--options(.*)-->/, @copy );
}

######################################################################
# Done!
######################################################################

1;

