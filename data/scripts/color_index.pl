#!/usr/bin/env perl

# color_index.pl
# Justin White
# (C) 2001

# put in the wild world under the MIT software license
# see: http://www.opensource.org/licenses/mit-license.html
# this means you can do whatever you want with it
# as long as you attribute this little chunk of code to me

# usage: run it, it spits out valid XHTML

# version 1 final no more done period

# displays the 216 "web-safe" colors, plus the 6 safe greyscale color

# yeah so they ain't so safe anymore, but i like em
# many are a cool pastelish color that i like

# gimme a header
print
	qq|Content-type:text/html\n\n|,
	qq|<?xml version="1.0" encoding="UTF-8"?>\n|,
	qq|<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "DTD/xhtml1-strict.dtd">\n|,
	qq|<html lang="en" xml:lang="en">\n|,
	qq|<head>\n|,
	qq|<title>Justin's "Web Safe" Color Index></title>\n|,
	qq|</head>\n\n|,
	qq|<body style="background-color:#666666; color:#CCCCCC">\n\n|,
	qq|<h1 style="text-align:center">Justin's "Web Safe" Color Index</h1>\n\n|,
;

# start the greyscale table
print
	qq|<h2 style="text-align:center">Grey Scale</h2>\n|,
	qq|<table width="100%" cellspacing="4" border="0" style="text-align: center">\n|,
	qq|<tr>\n|
;

# find my greys!
for ($index1 = 0 ; $index1 <= 255 ; $index1 += 51) {
	print qq|<td style="|;
	printf qq|background-color:#%02X%02X%02X; |, $index1, $index1, $index1;
	printf qq|color:#%02X%02X%02X">|, 255-$index1, 255-$index1, 255-$index1;
	printf qq|#%02X%02X%02X\n|, $index1, $index1, $index1;
	print qq|</td>\n|;
}
print qq|</tr>\n</table>\n|;
	
	
# start the full table
print
	qq|<h2 style="text-align:center">All Colors</h2>\n|,
	qq|<table style="width:100%" cellspacing="4" border="0">\n|
;

# gimme those colors
for ($index1 = 0 ; $index1 <= 255 ; $index1 += 51) {
	for ($index2 = 0 ; $index2 <= 255 ; $index2 += 51) {
		print qq|<tr>\n|;
		for ($index3 = 0 ; $index3 <= 255 ; $index3 += 51) {
			print qq|\t<td style="text-align:center; |;
			printf qq|background-color:#%02X%02X%02X; |, $index1, $index2, $index3;
			printf qq|color:#%02X%02X%02X">|, 255-$index1, 255-$index2, 255-$index3;
			printf qq|<a name="%02X%02X%02X">|, $index1, $index2, $index3;
			printf qq|#%02X%02X%02X\n|, $index1, $index2, $index3;
			print qq|</td>\n|;
		}
		print qq|</tr>\n|;
	}
}

# all done, clean up
print
	qq|</table>\n\n|,
	qq|</body>\n\n|,
	qq|</html>\n|,
;

# end of program

