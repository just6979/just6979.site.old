#!/usr/bin/env python

import cgi
import Cookie
import getopt
import os
import sys
import time
import traceback

from scgi import scgi_server

def handle(env, input, output):
	def wl(msg):
		output.write(msg + "\n")

	valid_login = False

	passwd_filename = "passwd"

	form = cgi.FieldStorage(env)

	cookie = Cookie.SimpleCookie()

	op = form.getfirst("op", "")

	user = ""
	session = ""

	if "HTTP_COOKIE" in os.environ:
		cookie_str = os.environ["HTTP_COOKIE"]
		cookie.load(cookie_str)
		if "user" in cookie:
			user = cookie["user"].value
		if "session" in cookie:
			session = cookie["session"].value

	if not user:
		cookie["session"] = time.time()
		cookie["session"]["expires"] = -1 * 24 * 60 * 60
		session = ""
		wl(cookie.output())

	if session:
		valid_login = True

	if op == "signin":
		cookie["user"] = user
		# expire in yesterday to delete
		cookie["user"]["expires"] = -1 * 24 * 60 * 60
		user = ""
		cookie["session"] = time.time()
		cookie["session"]["expires"] = -1 * 24 * 60 * 60
		session = ""
		wl(cookie.output())
		valid_login = False
	elif op == "login":
		# get user from the form, or use the cookie, or the default ""
		user = form.getfirst("user", user)
		password = form.getfirst("password", "")
		found_user = ""
		found_password = ""
		if user:
			cookie["user"] = user
			# expire in 30 days
			cookie["user"]["expires"] = 30 * 24 * 60 * 60
			#cookie["user"]["path"] = "/scripts/"
			passwd_file = file(passwd_filename)
			for line in passwd_file:
				found_user, found_md5 = line.rstrip().split(":")
				if found_user == user:
					break
			if found_md5 == password:
				cookie["session"] = time.time()
				# expire in 30 days
				#user_cookie["expires"] = 30 * 24 * 60 * 60
				#cookie["session"]["path"] = "/scripts/"
				valid_login = True
			else:
				valid_login = False
			wl(cookie.output())
	elif op == "logout":
		cookie["session"] = time.time()
		# expire in 30 days
		cookie["session"]["expires"] = -1 * 24 * 60 * 60
		#cookie["session"]["path"] = "/scripts/"
		wl(cookie.output())
		session = ""
		valid_login = False


	wl('Content-type: text/html\n')
	wl('<html>\n<head>\n<title>Login</title>')
	wl('<script type="text/javascript" src="/js/md5.js"> </script>')
	wl('</title>\n<body>')

	wl('<h1><a href="./login.py">Login</a></h1>')

	if user:
		wl('<p>If this isn\'t <strong>%s</strong>, then <a href="?op=signin">sign in</a> as someone else.</p>' % user)

	if valid_login == True:
		wl('<p>You are %s and you are logged in! <a href="?op=logout">Logout?</a></p>' % user)
	else:
		wl('<form action="" method="GET" onsubmit="password.value=hex_md5(password.value)">')
		wl('User: <input type="text" name="user"value="%s"/>\n' % user)
		wl('<br />')
		wl('Password: <input type="password" name="password" />')
		wl('<br />')
		wl('<input type="submit" name="op" value="login"/>')
		wl('</form>')


	wl('</body>\n</html>')


class Handler(scgi_server.SCGIHandler):
    def produce(self, env, bodysize, input, output):
		try:
			handle(env, input, output)
		except:
			output.write('Content-type: text/html\n\n')
			output.write("<pre>\n")
			traceback.print_exc(file=output)
			output.write("</pre>\n")

if __name__ == "__main__":
	port = 8888
	opts, args = getopt.getopt(sys.argv[1:], "p:", ["port"])
	for opt, arg in opts:
		if opt in ["-p", "--port"]:
			port = int(arg)
	if "serve" in args:
		server = scgi_server.SCGIServer(
			handler_class=Handler,
			port=port
		)
		server.serve()
	else:
		handle(os.environ, sys.stdin, sys.stdout)
