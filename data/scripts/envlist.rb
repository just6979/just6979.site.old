#!/usr/bin/env ruby

# envlist.rb
# Justin White
# (C) 2002

# usage: put it on your server somewhere that it can be run
#	and point a browser to it

# http header
print "Content-type: text/plain\n\n";

# print the important stuff
ENV.keys.sort.each do |key|
	print "#{key} => #{ENV[key]}\n"
end

## EOF
