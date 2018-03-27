#!/usr/bin/env perl

use strict;
use warnings;

print "Content-type: text/html\n\n";

my %apps = (
	GCC => "gcc -v 2>&1",
	Apache => "apachectl -v",
	Perl => "perl -v",
	#Irssi => "irssi -v",
	OpenSSH => "ssh -V 2>&1",
	#Mutt => "mutt -v",
	VIM => "vim --version",
	Bash => "bash --version",
	Screen => "screen -v",
	Sudo => "sudo -V",
	#NASM => "nasm -v",
	Python => "python -V 2>&1",
	Ruby => "ruby --version",
	Samba => "smbclient -V",
	#CVSup => "cvsup -v",
);

print qq|<dl>\n|;

my $os = `uname -srpi`;
print
	qq|<dt>Operating System</dt>\n\t<dd>|,
	$os,
	qq|</dd>\n|
;

foreach my $app (sort keys %apps) {
	my $cmd = $apps{$app};
	my @file = split(" ", $cmd);
	my @tmp = `$cmd`;
	my $output = $tmp[0];
	$output = $tmp[0] if $app eq "Apache";
	$output = $tmp[1] if $app eq "Perl";
	$output = $tmp[4] if $app eq "GCC";
	$output = $tmp[2] if $app eq "CVSup";
	chomp $output;
	print
		qq|<dt>$app</dt>\n|,
		qq|\t<dd>$output</dd>\n|,
	;
}
print qq|</dl>\n|;

__END__
