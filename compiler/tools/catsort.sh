#! /bin/sh
# $Id: catsort.sh 4114 2010-11-09 16:25:15Z kena $
set -e
exec sed -e 's/^\([a-z]*\)\([0-9]\)\([^0-9]*\)$/\1@\2\3/g' | \
  sort | \
  sed -e 's/\([a-z]\)@*/\1/g'
