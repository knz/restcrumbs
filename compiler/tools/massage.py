#! /usr/bin/env python
# $Id: massage.py 4114 2010-11-09 16:25:15Z kena $

import sys
import notes
import re

thenote = sys.argv[1]
outfile = sys.argv[2]
insref = int(sys.argv[3])
makemath = int(sys.argv[4])

notes.init_repo(sys.argv[5:])

note = notes.repo.get(thenote)
deps = note.get_deps()
deps.sort(notes.cmpkey)

print "%s.txt(note) -> %s(transformable reST%s%s)" \
    % (thenote, outfile, insref and ', with "References"' or "", makemath and ', with math' or '')
f = file(outfile, 'w')
if makemath:
   print >>f, """
.. role:: math(raw)
   :format: latex html
"""

print >>f, """
.. |globeicon| image:: im/globe.png
.. |printicon| image:: im/printer.png
.. |docicon| image:: im/doc.png
.. |texicon| image:: im/tex.png

"""

cnt = note.contents.split('\n')

pat = re.compile('^:([^:]*):\s*\$[^:]*:\s*(.*)\$\s*$')
if insref and thenote.startswith('book'):
    color = note.get_color()
    cnt[1] += ' (the %s book)' % color

st = note.get_status()
if st == "obsolete":
    cnt[1] = '(Obsolete) ' + cnt[1]

cnt[0] = cnt[2] = cnt[0][0] * (len(cnt[1]) + 2)

for l in cnt:
   m = pat.match(l)
   if m is None:
       print >>f, l
   else:
       print >>f, ":%s: %s" % m.groups()

if (insref):
    print >>f
    if thenote.startswith('book'):
        print >>f, "============"
        print >>f, " References"
        print >>f, "============"
    else:
        print >>f, "References"
        print >>f, "=========="

for d in deps:
    print >>f
    print >>f, ".. include:: %s.ref" % d
f.close()

 
