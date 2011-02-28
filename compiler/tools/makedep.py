#! /usr/bin/env python
# $Id: makedep.py 1054 2008-12-03 00:38:43Z kena $

import sys
import notes

thenote = sys.argv[1]
outfile = sys.argv[2]

notes.init_repo(sys.argv[3:])

note = notes.repo.get(thenote)
deps = note.get_deps()

print "%s.txt(note) -> %s(referenced keys)" % (thenote, outfile)
f = file(outfile, 'w')
for d in deps:
    print >>f, d
f.close()







