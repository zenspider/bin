#!/usr/bin/perl -w

######################################################################
# CVS Info:
#
# $Id: //depot/main/user/ryand/Bin/HTML.pl#2 $
#
# $Log: HTML.pl,v $
# Revision 1.2  1999/01/29 02:15:37  ryand
# Fixed shebang line
#
# Revision 1.1.1.1  1998/11/26 08:41:22  ryand
# Added to repository.
#
# Revision 1.1.1.1  1998/09/14 22:04:44  ryand
# Imported sources
#
# Revision 1.4  1997/01/24 00:10:32  ryand
# Changed option handling routines to deal with perl 4 greedy regex algorithms
#
# Revision 1.3  1997/01/14 01:01:41  ryand
# Reformatted whitespace.
# Removed package specification and moved things into main namespace
# for better usability.
#
# Revision 1.2  1996/12/19 19:41:29  ryand
# Experimenting with cvs keywords
#
#
######################################################################

######################################################################
#
# Filename : HTML.pl
# Author   : Ryan Davis (RWD) <mailto:zss@POBoxes.com>
#
# Purpose  : Define a set of EASY TO USE, SIMPLE, and USEFUL
#		   : routines for creating WebLint compliant HTML output.
#
# Revisions:
# 1.2.0	   12/17/96 Added much improved options system, and reduced
#                   size by 2 pages!
# 1.1.0	   12/16/96 Filled out the tags based on SSC's HTML Reference.
# 1.0.1	   12/15/96 Added a few tags and fixed some Lint errors.
# 1.0.0	   12/14/96 Birthday.
#
######################################################################

#use strict;

#package HTML;

require "ctime.pl";

$author = "Ryan Davis";
$authorEmail = "zss\@POBoxes.com";
$contentType = ""; # Change to mime type for CGI Stuffs

################################################################
# Document Structure

	############################################################
	#
	# sub html
	#
	#	title: (string) title of the document.
	#	options: (string) options for HTML tag, if any.
	#
	#	returns: (string) full html document.
	#
	############################################################

sub html {

	local($title) = shift;

	$title = "Untitled"	if ! $title;

	#
	# FIX/NOTE: All the "\n" elements below are to be considered a KLUDGE!
	# There should be logic in the system to know which tags may
	# automatically embed newlines and which shouldn't (in order to
	# cleanly pass WebLint w/ all flags on, that is...)
	#

	return ($contentType ne "" ? "Content-type: $contentType\n\n" : "")
	. &optTag("!DOCTYPE", &options("HTML PUBLIC \"-//W3C//DTD HTML 3.2//EN\""))
	. "\n"
	. &optPair("HTML", "\n",
		&pair( "HEAD", "\n",
			&optTag("LINK", &options("REV=MADE HREF=\"mailto:$authorEmail\"")
			       ), "\n",
			&pair("TITLE", $title), "\n",), "\n",
		&pair("BODY", "\n",
			join('', @_), "\n",
			&rule, "\n",
			&p( "\n",
				&address( "\n",
					&anchor(
						&options(
							"HREF="
							. &url(
								"mailto:",

	$authorEmail,
							),
						),
						$author,
					), "\n",
				), "\n",
			), "\n",
			&p( "\n",
				&small( "\n",
					"Automatically generated on	",
					&ctime(time),
					" using	HTML.pl	by:	",
					&anchor(
						&options("HREF=" .
&url("\"mailto:zss\@POBoxes.com\"")),
						"Ryan Davis"
					), "\n",
				), "\n",
			), "\n",
		), "\n",
	);
}

################################################################
# Emphasis and Fonts
#
# All Emphasis and Font subroutines take any number of scalar
# values as it's input, and produce a string in the form of:
#	"<TAG>@_</TAG>

# Physical Styles:

sub bold		{ return &pair("B",			@_); }
sub big			{ return &pair("BIG",		@_); }
sub italic		{ return &pair("I",			@_); }
sub small		{ return &pair("SMALL",		@_); }
sub strike		{ return &pair("S",			@_); }
sub subscript	{ return &pair("SUB",		@_); }
sub superscript	{ return &pair("SUP",		@_); }
sub typewriter	{ return &pair("T",			@_); }
sub underline	{ return &pair("TT",		@_); }

# Logical Styles:

sub abbrev		{ return &pair("ABBREV",	@_); }
sub acronym		{ return &pair("ACRONYM",	@_); }
sub author		{ return &pair("AU",		@_); }
sub cite		{ return &pair("CITE",		@_); }
sub del			{ return &pair("DEL",		@_); }
sub dfn			{ return &pair("DFN",		@_); }
sub emphasis	{ return &pair("EM",		@_); }
sub insert		{ return &pair("INS",		@_); }
sub keyboard	{ return &pair("KEY",		@_); }
sub lang		{ return &pair("LANG",		@_); }
sub person		{ return &pair("PERSON",	@_); }
sub quote		{ return &pair("Q",			@_); }
sub sample		{ return &pair("SAMP",		@_); }
sub strong		{ return &pair("STRONG",	@_); }
sub variable	{ return &pair("VAR",		@_); }

################################################################
# Text Offsets

sub address		{ return &pair("ADDRESS",		@_); }
sub blockquote	{ return &pair("BLOCKQUOTE",	@_); }
sub code		{ return &pair("CODE",			@_); }

sub center		{ return &p( &options('ALIGN="CENTER"'), @_); }

sub pre			{ return &optPair("PRE", @_); }

################################################################
# Headers

sub h1 { return	&optPair("H1",	@_); }
sub h2 { return	&optPair("H2",	@_); }
sub h3 { return	&optPair("H3",	@_); }
sub h4 { return	&optPair("H4",	@_); }
sub h5 { return	&optPair("H5",	@_); }
sub h6 { return	&optPair("H6",	@_); }
sub h7 { return	&optPair("H7",	@_); }

################################################################
# Images

	############################################################
	#
	# sub image
	#
	#	url: result from &url pointing to image
	#	alt: string representing image's alt. description
	#	@_ : more options
	#
	#	returns: string representing HTML image tag.
	#
	############################################################

sub image {
    local($url) = shift;
    local($alt) = shift;

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

sub anchor		{ return &optPair("A", @_); }

################################################################
# Lists

sub dir			{ return &optPair("DIR",	@_); }
sub menu		{ return &optPair("MENU",	@_); }
sub listHeader	{ return &optPair("HL",		@_); }
sub list		{ return &optPair("UL",		@_); }
sub orderedList	{ return &optPair("OL",		@_); }
sub listItem	{ return &optPair("LI",		@_); }
sub dictionary	{ return &optPair("DL",		@_); }
sub dictTerm	{ return &optPair("DT",		@_); }
sub dictDef		{ return &optPair("DD",		@_); }

################################################################
# Separators

sub br			{ return    &pair("BR",		@_); }
sub division	{ return &optPair("DIV",	@_); }
sub p			{ return &optPair("P",		@_); }
sub rule		{ return  &optTag("HR",		@_); }

################################################################
# Comments

sub comment		{ return join('', "<!--", @_, "-->"); }

################################################################
# Forms
#
# I	have no	plans to do	forms at this time.

################################################################
# CGI
#
# I	have no	plans to do	CGI	at this	time,
# however, the html	sub	does start with	the
# "Content-type: text/html"	tag.

################################################################
# Tables and Figures

sub table		{ return &optPair("TABLE",		@_); }
sub row			{ return &optPair("TR",			@_); }
sub cell		{ return &optPair("TD",			@_); }
sub cellHeader	{ return &optPair("TH",			@_); }
sub caption		{ return &optPair("CAPTION",	@_); }

################################################################
# URLS

# TODO: add url validation

sub url			{ return join('', @_); }

################################################################
# Special Characters

# TODO: iso8859 2 way filter

################################################################
# Miscellaneous	Subroutines

	############################################################
	#
	# sub options [public]
	#
	#	@_:	(scalars) data to embed as options in HTML tag
	#
	#	Example:
	#
	#		&dictionary( &options("COMPACT"), ... );
	#
	#	returns: private string to be decoded internally.
	#
	############################################################

sub options { return "<!--options" . join(" ", @_, "\cE") . "-->"; }

	############################################################
	#
	# sub pair [private]
	#
	#	tag: (string) HTML tag for pair
	#	@_:	(scalars) rest of data to embed	in pair
	#
	#	returns: (string) form of "<TAG> @_ </TAG>"
	#
	############################################################

sub pair {
	local($tag) = shift;

	return &tag($tag) . join('', @_) . &endTag($tag);
}

	############################################################
	#
	# sub optPair [private]
	#
	#	tag: (string) HTML tag for pair
	#	options: (string) options to embed in tag
	#	@_:	(scalars) rest of data to embed	in pair
	#
	#	returns: (string) form of "<TAG	OPT> @_	</TAG>"
	#
	############################################################

sub optPair	{
	local($tag) = shift;

	return &optTag($tag, @_) . join('', &nonOptions(@_)) . &endTag($tag);
}

	############################################################
	#
	# sub tag [private]
	#
	#	tag: (string) HTML tag to create
	#
	#	returns: (string) tag in form of "<TAG>"
	#
	############################################################

sub tag	{
	local($tag) = shift;

	return "<$tag>\n";
}

	############################################################
	#
	# sub endTag [private]
	#
	#	tag: (string) HTML end-tag to create
	#
	#	returns: (string) tag in form of "</TAG>"
	#
	############################################################

sub endTag {
	local($tag) = shift;

	return "</$tag>\n";
}

	############################################################
	#
	# sub optTag [private]
	#
	#	tag: (string) HTML tag to create
	#	options: (string) options to embed in tag
	#
	#	returns: (string) tag in form of "<TAG OPT>"
	#
	############################################################

sub optTag {
	local($tag) = shift;
	local(@options) = &getOptions(@_);

	return "<$tag" . (@options ?  " " . join(" ", @options) : "") . ">";
}


	############################################################
	#
	# sub getOptions [private]
	#
 	#	returns: (array) array of options (w/o option tags)
	#
	############################################################

sub getOptions {
	local(@copy) = @_;

	return grep ( s/^<!--options([^\cE]*)\cE-->$/$1/, @copy );
}

	############################################################
	#
	# sub nonOptions [private]
	#
	#	returns: (array) array w/o options
	#
	############################################################

sub nonOptions {
	local(@copy) = @_;

	return grep (!m/^<!--options([^\cE]*)\cE-->$/, @copy );
}

######################################################################
# Done!
######################################################################

1;
