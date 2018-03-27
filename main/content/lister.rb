#!/usr/local/bin/ruby

=begin

input files are arguments + '.list' formatted as:

--cut--
[category]

URL
title
optional comment (author, artist, edition, etc)

URL
title

[new category]

URL
title
optional comment
--cut--

output files are argument + '.htf' formatted as:

--cut--
<h3category</h3>
<ol>
<li><a href="URL">title</a>, optional comment</li>
<li><a href="URL2">title2</a>, optional comment2</li>
</ol>
--cut--

=end

# handle multiple files in the arguments
ARGV.length.times do |i|
	input = ARGV[i]
	output = input
	output = output.split('.')[0] + '.htf'
	print "reading " + input + "...\t"
	## parse
	# set up category storage
	comment = []
	categories = {}
	file = File.open input
	file.each do |line|
		line.chomp!
		next if line.empty?
		# check for category changes
		if line =~ /\[(.*)\]/
			category = $1
			if category != 'comment'
				# set up title storage
				categories[category] = {}
				@titles = categories[category]
			else
				# the comment
				categories['comment'] = file.gets.chomp
			end
			next
		end
		# not empty, not category, must be a new entry
		url = line
		# get title on next line
		title = file.gets.chomp
		# get next line
		comment = file.gets.chomp
		# if we found a comment, discard the following blank line
		file.gets unless comment =~ /^$/
		# store info for each title found
		@titles[title] = [url, comment]
	end
	file.close
	print "read  " + input + "\n"

	## output
	outfile = File.open output, File::TRUNC|File::CREAT|File::WRONLY, 0664
	print "Writing " + output + "... \t"
	outfile.puts '<div id="list-comment">'
	outfile.puts '<p>'
	outfile.puts categories['comment']
	outfile.puts '</p>'
	outfile.puts '</div>'
	categories.delete 'comment'
	categories.keys.sort.each do |category|
		outfile.puts '<div class="category">'
		outfile.puts "<h3>#{category}</h3>"
		outfile.puts '<ol>'
		titles = categories[category]
		titles.keys.sort.each do |title|
			url = titles[title][0]
			comment = titles[title][1]
			outfile.print "<li><a href=\"#{url}\">#{title}</a>"
			outfile.print ", #{comment}" if comment !~ /$^/
			outfile.print "</li>\n"
		end
		outfile.puts '</ol>'
		outfile.puts '</div>'
	end
	print "Wrote " + output + "\n"
end

