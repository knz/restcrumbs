# 
# GNUMakefile: this file is part of the RestCrumbs publisher.
#
# Copyright (C) 2011 The RestCrumbs Project.
#
# Redistribution and use in source and binary forms, with or without modification, are
# permitted provided that the following conditions are met:
#
#    1. Redistributions of source code must retain the above copyright notice, this list of
#       conditions and the following disclaimer.
#
#    2. Redistributions in binary form must reproduce the above copyright notice, this list
#       of conditions and the following disclaimer in the documentation and/or other materials
#       provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE RESTCRUMBS PROJECT ``AS IS'' AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are those of the
# authors and should not be interpreted as representing official policies, either expressed
# or implied, of The RestCrumbs Project.


#####################
# Source documents 
SOURCES := $(filter-out book%,$(wildcard [a-z]*[0-9]*.txt))
DIAGRAMS := $(wildcard im/*.dot)

#####################
# Selection of notes for the SVP reference document
GLOSSARIES := $(patsubst %.txt,%,$(wildcard glo*.txt))

#####################
# Selection of notes for the index
INDEXEDNOTES := $(SOURCES) $(GLOSSARIES:glo%=book%.txt) idx.txt

#################
# Build tools
AWK = awk
PYTHON = python
RST2HTML = tools/wrapper.sh rst2html -i latin-1:strict --exit-status=2 \
	   --toc-entry-backlinks --toc-top-backlinks
RST2LATEX = tools/wrapper.sh rst2latex -i latin-1:strict --exit-status=2 \
	    --docutils-footnotes --use-latex-citations --use-latex-toc \
	    --latex-preamble=""
RST2S5 = tools/wrapper.sh rst2s5 --exit-status=2 --theme=small-black
PDFLATEX = tools/wrapper.sh pdflatex
DOT2PNG = tools/wrapper.sh dot2png
SVN = svn
SPHINX = $(HOME)/custom-python/bin/sphinx-build

##################
# General rules

NOTES := $(INDEXEDNOTES) index.txt

.PHONY: all clean text pdf tidy dep check purge web
.SUFFIXES: log aux out pdf ltx html txt ref tex \
	rst rstr rstrx png dep check add col hcol d idx

all: text

text: $(NOTES)

pdf: $(NOTES:.txt=.pdf)

tex: $(NOTES:.txt=.tex)

#######################
# Sphinx rules

COMPANIONS := $(NOTES) $(NOTES:.txt=.pdf) $(NOTES:.txt=.tex)
SPHINXSRC := $(NOTES:.txt=.rstr) $(NOTES:.txt=.ref)
www/index.html: $(COMPANIONS) $(SPHINXSRC) tools/conf.py
	for i in $(filter-out %.py,$(filter-out %.rstr,$?)); do \
	  cp -f "$$i" www/; \
	done
	rm -f www/genindex.html
	$(SPHINX) -b html -c tools/ . www/
	ln -sf idx.html www/genindex.html
	mkdir -p www/_sources
	(cd www/_sources && ln -sf ../*.txt .)

web: www/index.html

#######################
# Main derivation rules

%.rst: %.txt tools/massage.py tools/notes.py
	@$(PYTHON) tools/massage.py "$*" "$@" 0 1 $(NOTES:.txt=)

%.rstr: %.txt tools/massage.py tools/notes.py
	@$(PYTHON) tools/massage.py "$*" "$@" 1 0 $(NOTES:.txt=)

%.rstrx: %.txt tools/massage.py tools/notes.py
	@$(PYTHON) tools/massage.py "$*" "$@" 1 1 $(NOTES:.txt=)

%.tex: %.rst tools/wrapper.sh
	@if test 0 != `expr "$@" : "book"`; then \
	   echo '$<(transformable reST) -> $@(LaTeX book snippet)'; \
	   color=`grep -i "^:Color:" <"$<"|head -n 1|cut -d: -f3`; \
	   color=`echo $$color`; \
	   $(RST2LATEX) --no-doc-title --no-section-numbering --documentclass=book --embed-stylesheet --stylesheet=sty/$$color.col "$<" "$@".tmp || (rm -f "$@".tmp; false) ; \
	 else \
	   echo '$<(transformable reST) -> $@(LaTeX snippet)'; \
	   $(RST2LATEX) --no-doc-info --no-doc-title --no-section-numbering --embed-stylesheet --documentclass=book --stylesheet=sty/notes.sty "$<" "$@".tmp || (rm -f "$@".tmp; false); \
	 fi
	@awk -v p=0 \
	  '{ if ($$0 ~ /\\(begin|end){(document|thebibliography)}/) { print "%%", $$0; p = !p; } else if (p) print $$0; else print "%%", $$0; }' \
	  "$@".tmp >"$@" || (rm -f "$@"; false)
	@rm -f "$@".tmp


%.ltx: %.rst tools/wrapper.sh
	@if test 0 != `expr "$@" : "book"`; then \
	   echo '$<(transformable reST) -> $@(LaTeX book)'; \
	   color=`grep -i "^:Color:" <"$<"|head -n 1|cut -d: -f3`; \
	   color=`echo $$color`; \
	   $(RST2LATEX) --no-section-numbering --documentclass=book --stylesheet=sty/$$color.col "$<" "$@" \
	      || (rm -f "$@"; false);  \
	 else \
	   echo '$<(transformable reST) -> $@(LaTeX)'; \
	   $(RST2LATEX) --stylesheet=sty/notes.sty "$<" "$@" || (rm -f "$@"; false); \
	 fi

%.p.html: %.rstrx tools/wrapper.sh
	@echo '$<(transformable reST, with "References" + math) -> $@(S5 presentation)'
	$(RST2S5) "$<" "$@"

%.pdf: %.ltx tools/wrapper.sh sty/notes.sty
	@echo '$<(LaTeX) -> $@(PDF)'
	@$(PDFLATEX) "$<" && rm -f $*.{log,out,aux,toc}

%.col: sty/notes.sty sty/csabook.sty
	@echo 'Generating $@ ...'
	@cat sty/notes.sty >"$@"
	@echo "@def@bookcolor{$(@:sty/%.col=%)}" |tr @ '\\\\' >>"$@"
	@cat sty/csabook.sty >>"$@"

########################
# Derivation for diagrams
%.png: %.dot tools/wrapper.sh
	@echo "$<(Graphviz) -> $@(PNG)"
	@$(DOT2PNG) "$<" "$@"



########################
# Derivation for books

%.idx: %.txt tools/getidx.sh
	@echo "$<(reST glossary) -> $@(index)"
	@tools/getidx.sh "$<" >"$@"

idx.txt: $(GLOSSARIES:%=%.idx) tools/mergeidx.sh
	@echo "$(GLOSSARIES:%=%.idx) -> $@(global index)"
	@tools/mergeidx.sh $(GLOSSARIES:%=%.idx) >"$@"

.INTERMEDIATE: $(GLOSSARIES:%=%.idx)

book%.txt: book%.spec glo%.txt tools/genref.sh tools/catsort.sh
	@echo "$<(reST glossary) -> $@(reST book)"
	@tools/genref.sh $* >"$@"

LEFTOVER_SOURCES = $(filter-out $(wildcard [a-z]*p[0-9]*.txt),$(filter-out glo%,$(SOURCES)))

book0.spec: $(wildcard book[1-9]*.spec) # $(LEFTOVER_SOURCES)
	@echo "Generating $@..."
	@rm -f $@.tmp
	@echo ":Book: Miscellaneous notes (not included in other books)" >$@.tmp
	@echo ":Color: gray" >>$@.tmp
	@echo >>$@.tmp
	@for nf in $(LEFTOVER_SOURCES); do \
	   n=`echo "$$nf"| cut -d. -f1`; \
	   if grep -qi ':status: *obsolete' <"$$nf"; then continue; fi; \
	   if grep -qi "$$n" book[1-9]*.spec; then continue; fi; \
	   echo ":Chapter: $$n" >>$@.tmp; \
	done
	@if ! cmp -s $@.tmp $@; then cp -f $@.tmp $@; fi
	@rm -f $@.tmp

#######################
# Verification rules

check: $(SOURCES:.txt=.check)

%.check: %.rst tools/check.sh
	@echo "checking note" $* "..."
	@tools/check.sh "$<"

########################
# SVN Rules

%.add: %.txt
	@if test $@ = index.add -o $@ = book2.add; then \
	   echo "This should not go to the repository."; \
	   exit 1; \
	 fi
	@chmod -x "$<"
	@$(MAKE) $*.check
	@$(SVN) add "$<"
	@$(SVN) propset svn:keywords "Id HeadURL" "$<"
	@$(SVN) propdel svn:executable "$<" || true

########################
# Clean rules
%.tidy:
	rm -f $*.aux $*.log $*.ltx $*.out $*.rst $*.ps $*.htmlx $*.toc $*.idx $*.rstrx

tidy: $(NOTES:.txt=.tidy)
	rm -f *\~ .\#* \#*\#

%.clean: %.tidy
	rm -f $*.pdf $*.ref $*.rstr

clean: tidy $(NOTES:.txt=.clean)
	rm -f $(DIAGRAMS:.dot=.png)
	rm -f im/deps.*
	rm -f sty/*.col sty/*.hcol
	rm -rf www/*


purge: clean
	rm -f .*.dep .*.d
	rm -f book*.txt index.txt idx.txt

#############################
# Automatic index generation

index.txt: tools/genindex.sh categories.csv $(INDEXEDNOTES)
	@echo "$(INDEXEDNOTES) -> $@(index of all notes)"
	@tools/genindex.sh categories.csv $(INDEXEDNOTES) >"$@"

index.ltx: index.rst $(INDEXEDNOTES:.txt=.ref) 
index.check: index.rst $(INDEXEDNOTES:.txt=.ref)

.INTERMEDIATE: index.ltx index.rstx

#################################
# Automatic dependency management

dep: $(INDEXEDNOTES:%.txt=.%.d)

.%.dep: %.txt tools/makedep.py tools/notes.py
	@$(PYTHON) tools/makedep.py $* "$@" $(NOTES:.txt=) 

.%.d: %.txt tools/makedepends.py tools/notes.py
	@$(PYTHON) tools/makedepends.py $* "$@" $(NOTES:.txt=)
	@if expr '$*' : 'book' >/dev/null; then \
	    deps=`grep ':Chapter:' <"$*.spec"|cut -d: -f3|sed -e 's/ *//g;s/$$/.txt/g'|tr '\n' ' '`; \
	    echo "$*.txt: $$deps" >>"$@"; \
	fi

%.ref: %.txt tools/makeref.sh
	@echo "$<(reST) -> $@(reference text)"
	@tools/makeref.sh "$<" >"$@"

im/deps.dot: $(SOURCES:%.txt=.%.dep) tools/gendiag.sh
	@echo ".*.dep -> $@"
	@tools/gendiag.sh $(SOURCES) >"$@"

include $(INDEXEDNOTES:%.txt=.%.d)
