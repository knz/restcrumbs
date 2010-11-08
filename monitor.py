#! /usr/bin/python

import os
import time
import traceback
import subprocess

clogs = os.path.join(os.getcwd(), 'logs')
ckeep = os.path.join(os.getcwd(), 'control', 'dokeep')
cmake = os.path.join(os.getcwd(), 'control', 'domake')
cup = os.path.join(os.getcwd(), 'control', 'doupdate')
cnotes = os.path.join(os.getcwd(), '..', 'notes')

def mkl(n):
	return os.path.join(clogs, n)

def mkt():
	return time.strftime('%Y%m%d%H%M%S', time.gmtime())

while True:
	time.sleep(5)
	ts = mkt()
	try:
		print "waking up at ", ts
		doupdate = False
		domake = False
		doall = False
		dokeep = False
		if os.path.exists(ckeep):
			dokeep = True
		if os.path.exists(cup):
			doupdate = True
			os.remove(cup)
		if os.path.exists(cmake):
			domake = True
			f = None
			r = None	
			try: 
				f = open(cmake)
				r = f.read()
				if r.strip().lower() == 'all': doall = True
			finally:
				f.close()
			r = None
			os.remove(cmake)

		if doupdate:
			n1 = mkl('%s.update.running' % ts)
			ul = open(n1, 'w', 0)
			code = subprocess.call(["svn","update"], stdout=ul, stderr=ul, cwd=cnotes)
			if code == 0:
				ul.close()			
				f = file(n1).read()
				if "Updating" in f:
					dorebuild = True
				if 'GNUmakefile' in f:
					doall = True
				if not dokeep: os.remove(n1)
				else: os.rename(n1, mkl('%s.update' % ts))
			else:
				print >>ul, "Command terminated with exit code: ", code
				ul.close()
				os.rename(n1, mkl('%s.update.bad' % ts))
		

	except:
		f = open(mkl('monitor'), 'a')
		print >>f, "--- %s ---" % ts
		traceback.print_exc(file = f)
		f.close()
