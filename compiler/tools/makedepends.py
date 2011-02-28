#! /usr/bin/env python
# $Id: makedepends.py 4114 2010-11-09 16:25:15Z kena $

depfmt = """
%(note)s.check: %(note)s.rst %(dl)s
%(note)s.ltx: %(note)s.rst %(dl)s %(pdf_stydep)s
%(note)s.tex: %(note)s.rst %(dl)s %(pdf_stydep)s
%(note)s.pdf: %(note)s.ltx %(imgs)s

.INTERMEDIATE: %(note)s.ltx %(note)s.rst
"""

import sys
import notes

thenote = sys.argv[1]
outfile = sys.argv[2]
notes.init_repo(sys.argv[3:])

note = notes.repo.get(thenote)

deps = ' '.join([d + '.ref' for d in note.get_deps()])
imgs = ' '.join(note.get_imgs())

c = note.get_color()
if c is not None:
    stydep2 = 'sty/%s.col' % c
else:
    stydep2 = 'sty/notes.sty'

f = depfmt % dict(note = thenote,
                  dl = deps,
                  imgs = imgs,
                  pdf_stydep = stydep2)

print "%s.txt(note) -> %s(make dependencies)" % (thenote, outfile)
file(outfile, 'w').write(f)


