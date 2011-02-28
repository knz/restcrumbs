#! /bin/sh
# $Id: check.sh 1529 2009-02-17 15:41:16Z mike $

D=`dirname "$0"`
WR=$D/wrapper.sh
MD=$D/makedep.sh
IN=$1
err=0
incerr () { 
  err=`expr $err + 1` 
}

set -e

if ! test -r "$IN"; then
  echo "$IN: file is not readable." >&2
  exit 1
fi

for md in Key Authors Date Status; do
  n=`grep -i "^:$md:" "$IN"|wc -l`
  if test $n = 0; then
    echo "$IN: missing :$md: field." >&2; incerr
  elif test $n -gt 1; then
    echo "$IN: multiple occurences of :$md:." >&2; incerr
  fi
done

for md in Version Source Abstract; do
  n=`grep -i "^:$md:" "$IN"|wc -l`
  if test $n = 0; then
    echo "$IN: field :$md: not found (but is optional)." >&2
  elif test $n -gt 1; then
    echo "$IN: multiple occurences of :$md:." >&2; incerr
  fi
done

bn=`basename "$IN"`
key=`grep -i '^:Key:' <"$IN"|head -n 1|cut -d: -f3`
key=`echo $key`
if test 0 = `expr "$bn" : "$key"'\.'`; then
   echo "$IN: key set with :Key: ($key) does not match filename" >&2
   incerr
fi

st=`grep -i '^:Status:' <"$IN"|head -n 1|cut -d: -f3`
st=`echo $st|tr 'A-Z' 'a-z'`
if test "$st" = "obsolete"; then
  if ! grep -q '^:ReplacedBy:' <"$IN"; then
    echo "$IN: note is marked obsolete but :ReplacedBy: is not set" >&2
    incerr
  fi
else
  repl=`grep -i '^:Replaces:' <"$IN"|head -n 1|cut -d: -f3`
  repl=`echo $repl`
  for d in `"$MD" "$IN" *.txt`; do
    st=`grep -i '^:Status:' <"$d".txt|head -n 1|cut -d: -f3`
    st=`echo $st|tr 'A-Z' 'a-z'`
    if test "$st" = "obsolete" -a "$d" != "$repl"; then
     echo "$IN: warning: reference to obsolete note [$d]" >&2
    fi
  done
fi

f=`mktemp -t checkXXXX`
$WR rst2latex --report=1 "$IN" 2>&1 >/dev/null|tee -a "$f" >&2
msgs=`cat "$f"|grep -v "INFO/1"|wc -l`
if test $msgs -gt 0; then
  err=`expr $err + $msgs`
fi
rm -f "$f"

if test $err != 0; then
  echo "$IN: $err problem(s) found." >&2
fi
exit $err
