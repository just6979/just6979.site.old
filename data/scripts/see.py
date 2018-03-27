#!/usr/bin/env python

import cgi, cgitb, os
cgitb.enable()

f_name = os.getenv('QUERY_STRING', 'see.py')

f = file(f_name)
print 'Content-type: text/plain\n'
print f.readlines()
