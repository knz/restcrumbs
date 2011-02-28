#! /bin/sh
# $Id: makedep.sh 1049 2008-12-02 23:40:23Z kena $
inp=$1
shift 1

set -e

for d in `tr '\t' '\n' <"$inp" | \
	     tr ' ' '\n' | \
	     grep '\[[a-zA-Z][-_a-zA-Z0-9]*\]_' | \
	     sed -e 's/^.*\[\([^]]*\)\]_.*$/\1/g' | \
	     sort | uniq`; do 
   for f in "$@"; do
     if test  "$d.txt" = "$f"; then 
      echo "$d"
     fi
   done
done
