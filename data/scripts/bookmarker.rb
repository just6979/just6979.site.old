#!/usr/bin/env ruby

=begin

= Synonpsis
Reads bookmarks file, generates HTML page with form, adds form input to file.

== File Format

Bookmark entries delimited by blank lines. URL and title delimited by newline.
Example:
--snip--
http://ruby-lang.org
Ruby

http://www.freebsd.org/
FreeBSD
--snip--

=end

require 'cgi'

class CGI
	def dump_source arg = 'source'
		if has_key? arg
			print "Content-Type: text/plain\n\n"
			File.open $0 do |file|
				print file.readlines
			end
			return true
		end
	end
end


class Bookmark
	def initialize url = nil, title = nil
		@url = url
		@title = title
		@title = url if @title == "" or @title.nil?
	end

	def url= url
		@url = url
	end

	def title= title
		@title = title
	end

	def url
		@url
	end

	def title
		@title
	end

	def to_s sep = ' @ '
		"#{title}#{sep}#{url}"
	end
end


class BookmarkList
	def initialize filename = nil
		@marks = Hash.new
		@filename = filename
		@count = 0
		read
	end

	def filename= name
		@filename = name
	end

	def read
		read_from @filename if @filename
	end

	def read_from filename
		@marks.clear
		add_from filename
	end

	def add_from filename
		File.open (filename, File::CREAT|File::RDONLY, 0664) do |file|
			file.each do |line|
				next if line =~ /^$/
				next if line =~ /^#/
				url = line.chomp
				title = file.gets.chomp
				add url, title
			end
		end
	end

	def write
		write_to @filename if @filename
	end

	def write_to filename
		File.open (filename, File::CREAT|File::TRUNC|File::WRONLY, 0664) do |file|
			file.puts to_s
		end
	end

	def add url, title
		mark = Bookmark.new url, title
		@marks[url] = mark
	end

	def delete url
		@marks.delete url
	end

	def empty?
		@marks.empty?
	end

	def each
		@marks.each do |url, mark|
			yield mark.url, mark.title
		end
	end

	def urls
		@marks.keys
	end

	def [] url
		@marks[url].title
	end

	def []= url, title
		mark = Bookmark.new url, title
		@marks[url] = mark
	end

	def to_s
		out = Array.new
		each do |url, title|
			out << url
			out << title
			out << "\n"
		end
		return out
	end

end

class Page
	def initialize cgi
		@cgi = cgi
		@list = BookmarkList.new "bookmarks"
	end

	def dispatch
		if @cgi.has_key? 'op'
			op = @cgi.params['op'].first
			case op
				when 'add'
					add
				when 'delete'
					delete
				when 'repair'
					old = BookmarkList.new "bookmarks.good"
					old.write_to "bookmarks"
					@list.read
			end
		end

		show
	end

	def add
		url = @cgi.params['url'][0]
		url = CGI.escapeHTML url
		title = @cgi.params['title'][0]
		title = CGI.escapeHTML title
		unless url == ""  or url.nil?
			@list[url] = title
			@list.write
		end
	end

	def delete
		url = @cgi.params['url'][0]
		url = CGI.escapeHTML url
		unless url == "" or url.nil?
			@list.delete url
			@list.write
		end
	end

	def show
		header
		puts "<form method=\"post\" action=\"#{$me}\">"
		print_list
		print_inputs
		puts '</form>'
		footer
	end

	def header
		puts '<?xml version="1.0" encoding="UTF-8"?> <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "DTD/xhtml1-strict.dtd">'
		puts '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">'
		puts '<head>'
		puts '<title>bookmarks</title>'
		puts '<link rel="stylesheet" type="text/css" href="/main.css" />'
		puts '</head>'
		puts '<body>'
		puts '<h1 id="content-title"><a href="/">tinfoil</a></h1>'
		puts '<div id="content">'
		puts "<div id=\"content-title\"><h2><a href=\"#{$me}\">bookmarks</a></h2></div>"
	end

	def print_list
		unless @list.empty?
			puts '<div style="border-bottom: solid thin;">'
			puts '<p class="noindent">'
			@list.urls.sort.each do |url|
				title = @list[url]
				#puts "<input type=\"radio\" name=\"url\" value=\"#{url}\" />"
				puts "<a href=\"#{url}\">#{title}</a><br />"
			end
			puts '</p>'
			puts '</div>'
		end
	end

	def print_inputs
		puts '<p class="noindent">'
		puts 'URL:'
		puts '<input type="text" name="url" size="50" /><br />'
		puts 'title:'
		puts '<input type="text" name="title" size="50" /> <em>(optional - defaults to URL)</em><br />'
		puts '<input type="submit" name="op" value="add" />'
		#puts '<input type="submit" name="op" value="delete" />'
		puts '<input type="reset" value="reset" />'
		#puts '<input type="submit" name="op" value="repair" />'
		puts '</p>'
	end

	def footer
		puts '</div>'
		puts '<div id="footer">'
		puts '<p>'
		puts '2002-2004 (C) <a href="mailto:just6979@yahoo.com">Justin White</a> |'
		puts '<a href="?source">view source</a> |'
		puts '<a href="http://validator.w3.org/check/referer"><img src="/images/valid_xhtml10.png" class="linkicon" alt="Valid XHTML 1.0" /></a>'
		puts '</p>'
		puts '</div>'
		puts '</body>'
		puts '</html>'
	end
end
## end Page


## main
begin
	cgi = CGI.new
	exit if cgi.dump_source

	$me = File.basename $0

	puts cgi.header 'text/html'

	page = Page.new cgi
	page.dispatch
end
## end main
