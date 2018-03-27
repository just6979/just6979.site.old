#!/usr/bin/env ruby

=begin
pass filename to view as CGI arguments. if none given, use self
examples:
'see.rb?envlist.pl' relative to pwd
'see.rb/index.html' relative to DocumentRoot
=end

print "Content-type: text/plain\n\n"

# use a pathname
file = ENV['PATH_TRANSLATED']
name = ENV['PATH_INFO']

# or the query string
unless file
	file = ENV['QUERY_STRING']
	name = file
end

# apache will generate an error on '*/.ht*'
# so block apache stuff anyway, use self
if file =~ "^.*/\.ht.*$"
	file = $0
	name = File.basename file
end

# or self
if file == nil
	file = $0
	name = File.basename file
end

puts file
puts
puts name
puts

# display the file
f = File.open name
puts f.read
f.close

__END__
