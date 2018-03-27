"""Playing with Apache, Python, PostgreSQL, and Genshi

Output:
	Reads a table from a SQL database served by PostgreSQL.
	Populates XML templates with the table data via Genshi
	Renders XHTML from populated Genshi templates.
Input:
	Gathers and processes form data from Apache.
	Inserts form data into the table.

The generated markup is valid XHTML 1.1, and the local CSS is valid.
Genshi will generate exceptions if the templates aren't valid XML, helping to ensure well-formed XHTML.
Apache and this code generate various HTTP headers to help transport and browser efficiency.
"""

import os
import sys
import time

# an exception will be generated if you import this module outside of mod_python/apache
# we ignore the exception to allow the module to be imported anywhere for testing
# and divert req.write() to stdout
try:
	from mod_python import apache, util
except:
	pass


from genshi.template import TemplateLoader
from pyPgSQL import PgSQL

# note where this file is to use as a base directory
baseDir = os.path.dirname(__file__)
# keep configuration files in a place where clients can't get them
configDir = "/home/www/config/"

# host where the db lives
dbHost = "localhost"
# user to connect to the db as
dbUser = "www"
# name of database to connect to
dbName = dbUser

# main page template
templateName = "datapage.xml"
# main page title
title = "Sandbox"

# main table in the db
table = "people"
# a list of fields in the table
fields = ("user_id", "name", "age", "location", "magic_num", "last_mod")
#fields = ["location", "make", "model", "year", "price", "drivetrain", "max_hp", "max_hp_after_oil", "max_hp_rpm", "max_torque", "max_torque_rpm", "length", "weight", "weight_to_power", "new_used_won", "won_from_1", "won_from_2", "used_lot", "selling_price", "lowest_mileage", "weeks_low_mileage_found"]
# fancy looking names for the fields
#fieldNames = ["Location", "Make", "Model", "Year", "Price", "Drivetrain", "Max HP", "Max HP (After Oil Change)", "Max HP @ RPM", "Max Torque", "Max Torque @ RPM", "Length", "Weight", "Weight To Power", "New-Used-Won", "Won From A", "Won From B", "Used Lot", "Selling Price", "Lowest Mileage Found", "Weeks Lowest Mileage Found"]
fieldNames = {"user_id": "ID", "name": "Name", "age": "Age", "location": "Location", "magic_num": "Magic #", "last_mod": "Last Modified"
}
# which field to sort by
order_by = "user_id"

# strftime format for HTTP Expires header, uses UTC/GMT
formatDateTime = "%a, %d %b %Y %H:%M:%S GMT"

## i think it's better to do these early so the connections will get cached
## i'm not positive if mod_python works like i think, so figure it out!

# get the templates ready to load up
"""note about using Genshi's XInclude bits:

you must put the 'xmlns:py="http://genshi.edgewall.org/"' declaration in any included
templates because genshi processes them before including them. without the declaration
the XML processor won't know how to handle the "py:" attributes.
"""

templateLoader = TemplateLoader(search_path=baseDir, auto_reload=True)

# read sqlpasswd (kept off tree for protection) to find the password
#passwordFile = os.path.join(configDir, "sqlpasswd")
#for line in file(passwordFile):
	#foundUser, foundPassword = line.split(":")
	#if foundUser == dbUser: break

# connect to the db
db = PgSQL.connect(host=dbHost, user=dbUser, database=dbName)
# maybe get a new cursor for each request? research mod_python's caching and such
cursor = db.cursor()

## end potential cached stuff

req = None
def handler(request):
	"""display() gets called from inside many other functions and needs access to req.
	So we make req visible globally instead of passing it all over the place."""
	global req
	req = request

	"""Handles a single request from the client, checking the form data for what to do.
	Calls functions to get data frm the DB and renders it as XHTML"""

	now = time.time()

	form = util.FieldStorage(req, keep_blank_values=True)

	req.update_mtime(now)
	req.set_last_modified()

	"""Since anything coming from this script may change at any time,
	we tell the client no to cache it."""
	req.headers_out["Date"] = time.strftime(formatDateTime, time.gmtime(time.time()))
	req.headers_out["Expires"] = time.strftime(formatDateTime, time.gmtime(time.time()))

	"""MS Internet Explorer doesn't understand application/xhtml+xml.
	If the request came from MSIE and lie to it, using text/html instead"""
	agent = req.headers_in["User-Agent"]
	if "MSIE" in agent:
		req.content_type = "text/html; charset=utf-8"
		#req.write("User-Agent is IE: %s" % agent)
	else:
		req.content_type = "application/xhtml+xml; charset=utf-8"
		#req.write("User-Agent is not IE: %s" % agent)

	"""Here we check the requested operation from the form, defaulting to select.
	Each operation funtion returns a boolean revealing if it was successful.
	If it was, we're happy and we tell the browser so.
	Otherwise, we tell the browser something went whacky."""
	op = form.getfirst("op", "select").lower()
	if op == "select":
		if display(): return apache.OK
	elif op == "insert":
		if insert(form): return apache.OK
	elif op == "delete":
		if delete(form): return apache.OK
	elif op == "update":
		if update(form): return apache.OK
	elif op == "dump":
		if dump(form): return apache.OK
	# nothing succeeded
	return apache.HTTP_BAD_REQUEST


def dump(form):
	req.content_type = "text/plain; charset=utf-8"
	"""send the content of a file to the client in the content div"""

	# what file did the user request, use myself by default
	filename = form.getfirst("file", os.path.basename(__file__))

	## make an absolute pathname
	filepath = os.path.join(baseDir, filename)

	# open the file to dump
	filedata = file(filepath, "r")

	# trim down the filepath to just the name
	filename=os.path.basename(filepath)

	for line in filedata:
		req.write(line)

	#template = templateLoader.load("dumper.xml")

	## give the template the right info to do a dump instead of a db operation
	#stream = template.generate(
		#filename=filename,
		#filedata=filedata,
	#)

	## write the XHTML
	#req.write(stream.render())

	return True;

def display(origQuery = None, errorMsg = None):
	global req
	template = templateLoader.load(templateName)

	# nice joined up string of fields to select
	joinedFields = ", ".join(fields)
	myQuery = " ".join(["SELECT", joinedFields, "FROM", table, "ORDER BY ", order_by, ";"])
	cursor.execute(myQuery)
	rows = cursor.fetchall()

	# if this select came after another myQuery, show the original
	if not origQuery:
		origQuery = myQuery

	stream = template.generate(
		title=title,
		fields=fields,
		fieldNames=fieldNames,
		rows=rows,
		dbName=dbName,
		origQuery=origQuery,
		errorMsg=errorMsg
	)
	req.write(stream.render())

	return True;


def insert(form):
	# find the next highest available ID
	cursor.execute("SELECT max(user_id)+1 FROM people;")
	user_id = cursor.fetchone()[0]

	# get quoted values (from fields global) to insert, from client
	values = []
	for field in fields:
		if field == "user_id":
			values.append(str(user_id))
		elif field == "last_mod":
			values.append("now()")
		else:
			values.append("'%s'" % form.getfirst(field, ""))

	# nice joined up strings to insert
	joinedFields = ", ".join(fields)
	joinedValues = ", ".join(values)

	# i guess maybe it could be called something other than "myQuery"
	myQuery = " ".join(["INSERT INTO", table, "(", joinedFields, ") VALUES (", joinedValues, ")"])

	try:
		cursor.execute(myQuery)
	except Exception, msg:
		return display(origQuery=myQuery, errorMsg=msg)
	else:
		## don"t forget to commit changes!!
		db.commit()
		# show results
		return display(origQuery=myQuery)


def update(form):
	user_id = form.getfirst("user_id", None)

	if user_id:
		values = []
		for field in fields[1:]:
			if field == "last_mod":
				values.append("last_mod=now()")
			else:
				values.append("%s='%s'" % (field, form.getfirst(field, "")))
		# nice joined up strings to update with
		joinedValues = ", ".join(values)
		# i guess maybe it could be called something other than "myQuery"
		myQuery = " ".join(["UPDATE", table, "SET", joinedValues, "WHERE user_id ='", user_id, "';"])
		try:
			cursor.execute(myQuery)
		except Exception, msg:
			return display(origQuery=myQuery, errorMsg=msg)
		else:
			## don"t forget to commit changes!!
			db.commit()
			# show results
			return display(origQuery=myQuery)
	else:
		return display(errorMsg="No user_id. You need to choose a row to UPDATE")

def delete(form):
	user_id = form.getfirst("user_id", None)

	if user_id:
		myQuery = ' '.join(["DELETE FROM", table, "WHERE user_id ='", user_id, "';"])
		try:
			cursor.execute(myQuery)
		except Exception, msg:
			return display(origQuery=myQuery, errorMsg=msg)
		else:
			## don"t forget to commit changes!!
			db.commit()
			# show results
			return display(origQuery=myQuery)
	else:
		return display(errorMsg="No user_id. You need to choose a row to DELETE.")


if __name__ == '__main__':
	req = sys.stdout
	display()
