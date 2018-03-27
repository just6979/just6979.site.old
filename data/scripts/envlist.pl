#!/usr/bin/env perl

# envlist.pl
# Justin White
# (C) 2001

# usage: put it on your server somewhere that it can be run
#	and point a browser to it

# http header
print "Content-type: text/plain\n\n";

# print the important stuff
foreach $key (sort keys %ENV) {
	print "$key => $ENV{$key}\n";
}

__END__
