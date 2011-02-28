#! /bin/bash

set -e

glos=''
for i in "$@"; do
  b=$(echo "$i"|sed -e 's/^[a-z]*\([0-9][0-9]*\)\([^0-9]*\)$/\1/g')
  glos="$glos $b"
done

defs=$( (for i in $glos; do \
         cat "glo$i".idx | sed -e 's/$/:'"book$i"'/g'; \
       done) | tr ' ' '`' | sort | uniq | tr '`' ' ' \
         | tr '\n' '`')
words=$(echo "$defs" | tr '`' '\n' | cut -d: -f1 \
          | tr ' ' '\n' \
          | sed -e 's/^ *//g;s/ *$//g;s/  */ /g' \
          | grep -v '^\(and\|or\|of\|with\|\)$' \
          | sort | uniq \
          | tr '\n' '`')

cat <<EOF
============
 Term index
============

:Key: idx
:Authors: Crumbs Collector
:Date: `date +%Y-%m-%d`
:Status: Generated
:Version: `date '+%Y-%m-%d %H:%M:%S'`
:Source: ``mergeidx.sh``

EOF

IFS='`'
for w in $words; do
  echo "$w"
  for l in $(echo "$defs" | tr '`' '\n' | grep "^[^:]*$w[^:]*:" | tr '\n' '`'); do
     d=$(echo "$l"|cut -d: -f2)
     r=$(echo "$l"|cut -d: -f3)
     echo "  $d [$r]_ |${r}h|_ |${r}p|_ |${r}t|_ |${r}x|_"
     echo
  done
done







 
