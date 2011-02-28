#! /usr/bin/python

print "Content-Type: text/html"
print

import cgitb
cgitb.enable()
import cgi
import os
import time
import sys
import glob

cdir = os.path.join(os.getcwd(), '..', 'control')
cmake = os.path.join(cdir, 'domake')
cup = os.path.join(cdir, 'doupdate')
cmon = os.path.join(cdir, 'active')
clogs = os.path.join(os.getcwd(), '..', 'logs')

form = cgi.FieldStorage()
if "action" in form:
	a = form.getvalue("action").lower()
	if a in ["check", "rebuild", "rebuild-all"]:
	   f = file(cup, 'w')
           f.close()
	if a in ["rebuild", "rebuild-all"]:
	   f = file(cmake, 'w')
	   if a == "rebuild-all": f.write("all")
	   f.close()

print "<html><head><title>Notes control interface</title></head><body>"
if not os.path.exists(cmon):
	print "<span style='font-weight: bold; color: red'>Monitor not active (check with sysadm!)</span>"
	
print "<ul><li>"
if os.path.exists(cmake):
   print "Build request issued at ", time.ctime(os.path.getctime(cmake))
   b = False
   try:
     f = file(cmake).read()
     if f.strip().lower() == 'all': b = True
   except: pass
   if b:
	print "(rebuild all)"
else:
   print "No build request pending."
print "</li><li>"
if os.path.exists(cup):
   print "Update request issued at ", time.ctime(os.path.getctime(cup))
else:
   print "No update request pending."
print "</li></ul><p><form action='%s' method='get'>" % os.path.basename(sys.argv[0])
print "<input type='submit' value='refresh' />: refresh this page only.<br />"
print "<input type='submit' name='action' value='check' />: check if files were updated, rebuild if any changes are found.<br />"
print "<input type='submit' name='action' value='rebuild' />: update files and rebuild only out-of-date targets.<br />"
print "<input type='submit' name='action' value='rebuild-all' />: update files and rebuild everything."
print "</form></p><h3>Process logs</h3>"

p = glob.glob(os.path.join(clogs, '*'))
if p:
	print "<table border='0'><tr><th width='30%'>Log file</th><th width='20%'>mtime</th></tr>"
	p.sort(reverse=True)
	for l in p:
		if "bad" in l:
			st = "style='background-color: red'"
		elif "running" in l:
			st = "style='background-color: green; font-weight: bold'"
		else:
			st = "" 
		mt = time.ctime(os.path.getmtime(l))
		bn = os.path.basename(l)
		url = '../logs/%s' % bn
		print "<tr><td %s><a href='%s'>%s</a></td><td>%s</td></tr>" % (st, url, bn, mt)
	print "</table>"
else:
	print "<i>No process logs yet.</i>"

print "</table></body></html>"
  
