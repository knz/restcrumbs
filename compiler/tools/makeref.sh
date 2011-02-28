#! /bin/sh
# $Id: makeref.sh 4114 2010-11-09 16:25:15Z kena $

set -e

get_status() {
  inp=$1
  st1=`grep -i '^:status:' <"$inp" |head -n 1|cut -d: -f3-`
  st1=`echo $st1`
  st2=`echo $st1|tr 'A-Z' 'a-z'`
  if test "$st2" = "obsolete"; then
    rpl=`grep -i '^:replacedby:' <"$inp"|head -n 1|cut -d: -f3-`
    rpl=`echo $rpl`
    st1="$st1 - replaced by **$rpl**"
  elif test "$st2" != "generated"; then
    rpl=`grep -i '^:replaces:' <"$inp"|head -n 1|cut -d: -f3-`
    rpl=`echo $rpl`
    if test -n "$rpl"; then
      st1="$st1 - replaces **$rpl**"
    fi
  fi
  echo "$st1"
}

IN=$1

title=`sed -n -e '2{p;q;}' <"$IN"|sed -e 's/^ *//g;s/ *$//g'`
date=`grep -i ':Date:' <"$IN"|head -n 1|cut -d: -f3-`
date=`echo $date`;
status=`get_status "$IN"`
key=`grep -i ':Key:' <"$IN"|head -n 1|cut -d: -f3-`
key=`echo $key`
ver=`grep -i ':Version:' <"$IN"|head -n 1|cut -d\$ -f2`
ver=`echo $ver`
cat <<EOF
.. [$key] |${key}h|_ |${key}p|_ |${key}t|_ |${key}x|_ $title.

   $date ($status) $ver

.. _\`${key}h\`: $key.html
.. |${key}h| replace:: |globeicon|
.. _\`${key}p\`: $key.pdf
.. |${key}p| replace:: |printicon|
.. _\`${key}t\`: $key.txt
.. |${key}t| replace:: |docicon|
.. _\`${key}x\`: $key.tex
.. |${key}x| replace:: |texicon|


EOF

