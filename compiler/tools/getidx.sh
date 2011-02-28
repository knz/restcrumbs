#! /bin/sh
# $Id: getidx.sh 1049 2008-12-02 23:40:23Z kena $

set -e

glo=$1
b=`basename "$glo" .txt`

words=$(grep '^_`' <"$glo" | sed -e 's/^_`\([^`(]*\)\(([^)]*)\)*`.*$/\1:\1\2/g;s/ *: */:/g;s/^ *//g;s/ *$//g'|tr ' ' '`'|sort|tr '`' ' '|uniq|tr '\n' '`')

IFS='`'
for w in $words; do
  echo "$w"
done
