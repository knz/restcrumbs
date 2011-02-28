#! /bin/bash 
D=`dirname "$0"`
CS="$D"/catsort.sh
catindex=$1; shift
set -e

keys=""
D="[0-9]"
for i in `echo "$@"|tr ' ' '\n'|"$CS"`; do
  bn=`basename "$i"`
  if grep -q ":Key:" "$i"; then
    key=`grep -i '^:Key:' <"$i"|head -n 1|cut -d: -f3`
    key=`echo $key`
    if test 0 = `expr "$bn" : "$key"'\.'`; then
      echo "Mismatch: file $i has :Key: set to $key" >&2
      exit 1
    fi
    if test "$key" != "index"; then
      date=`grep -i '^:Date:' <"$i"|head -n 1|cut -d: -f3`
      date=`echo $date`
      ver=`grep -i "^:Version:.*$D$D$D$D-$D$D-$D$D.$D$D:$D$D" <"$i"|head -n 1|\
           sed -e 's,^.*\('"$D$D$D$D-$D$D-$D$D\).\($D$D:$D$D"'\).*$,\1@\2,g'`
      ver=`echo $ver`
      if ! test -n "$ver"; then ver="(new)"; fi
      keys="$keys $key/$i/$date/$ver"
    fi
  fi
done

get_status() {
  inp=$1
  st1=`grep -i '^:status:' <"$inp" |head -n 1|cut -d: -f3-`
  st1=`echo $st1`
  st2=`echo $st1|tr 'A-Z' 'a-z'`
  if test "$st2" = "obsolete"; then
    rpl=`grep -i '^:replacedby:' <"$inp"|head -n 1|cut -d: -f3-`
    rpl=`echo $rpl`
    st1="$st1 - replaced by [$rpl]_"
  elif test "$st2" != "generated"; then
    rpl=`grep -i '^:replaces:' <"$inp"|head -n 1|cut -d: -f3-`
    rpl=`echo $rpl`
    if test -n "$rpl"; then
      st1="$st1 - replaces [$rpl]_"
    fi
  fi
  echo "$st1"
}

do_header() {
 cat <<EOF
=====================
 Index of all notes
=====================

:Key: index
:Authors: Crumbs Collector
:Date: `date +%Y-%m-%d`
:Status: Generated
:Version: `date '+%Y-%m-%d %H:%M:%S'`
:Source: ``genindex.sh``

.. contents::

EOF
}

do_catindex() {
  cat <<EOF

Notes by category
=================

Categories:

==================== ====================
Notes that match...  ... belong to:
==================== ====================
EOF
  exec < "$1"
  savef=$IFS
  IFS=','
  read a b # flush CSV header
  while read pat desc; do
    IFS=' '
    desc=`echo $desc`
    IFS=','
    printf '%-20s %s\n' '``'"$pat"'``' '`'"Category: $desc"'`_'
  done
  IFS=$savef
  cat <<EOF
==================== ====================

Index of all terms: [idx]_ |idxh|_ |idxp|_ |idxt|_ |idxx|_

EOF

}

do_onecat() {
  cat >/dev/null <<EOF
================ =====
Key              Title
================ =====
EOF
  pat=$1
  keys=$2
  savei=$IFS
  IFS=' '
  for kf in $keys; do
     k=`echo "$kf"|cut -d/ -f1`
     f=`echo "$kf"|cut -d/ -f2`
     if test 0 != `expr "$k" : "$pat"`; then
       st=`get_status "$f"`
       if ! echo "$st" | grep -q -i "obsolete"; then
         title=`sed -n -e '2{p;q;}' <"$f"`
         #printf '%-15s %s\n' "[$k]_" "$title"
         echo "[$k]_ |${k}h|_ |${k}p|_ |${k}t|_ |${k}x|_ ($st)"
         echo "  $title"
         echo
       fi
     fi
  done
  IFS=$savei
  echo "================ =====" >/dev/null
}

do_cats() {
  save=$IFS
  IFS=','
  exec < "$1"
  read a b # flush CSV header
  while read pat desc; do
    desc=`echo $desc`
    cat <<EOF
Category: $desc
-------------------------------------------------------------------

EOF
    do_onecat "$pat" "$2"
    echo
  done
  IFS=$save
}

do_chronindex() {
  savec=$IFS
  IFS=' 
'
  cat <<EOF

Notes in chronological order
============================

Notes already submitted
-----------------------

.. list-table::
   :widths: 20 20 40
   :header-rows: 1

   * - Submission date
     - Key
     - Title
EOF
  for n in `echo $1|tr ' ' '\n'|sort -t/ -k3`; do
    f=`echo "$n"|cut -d/ -f2`
    if grep -i "^:Status:" "$f"|head -n 1|grep -q -i "Submitted"; then
       k=`echo "$n"|cut -d/ -f1`
       d=`echo "$n"|cut -d/ -f3`
       title=`sed -n -e '2{p;q;}' <"$f"`
       echo "   * - $d"
       echo "     - [$k]_ |${k}h|_ |${k}p|_ |${k}t|_ |${k}x|_"
       echo "     - $title"
    fi
  done
  cat <<EOF


Draft notes
-----------

.. list-table::
   :widths: 20 20 40
   :header-rows: 1

   * - Last modification
     - Key
     - Title
EOF
  for n in `echo $1|tr ' ' '\n'|sort -t/ -k4`; do
    f=`echo "$n"|cut -d/ -f2`
    if grep -i "^:Status:" "$f"|head -n 1|grep -q -i "Draft"; then
       k=`echo "$n"|cut -d/ -f1`
       v=`echo "$n"|cut -d/ -f4|tr '@' ' '`
       title=`sed -n -e '2{p;q;}' <"$f"`
       echo "   * - $v"
       echo "     - [$k]_ |${k}h|_ |${k}p|_ |${k}t|_ |${k}x|_"
       echo "     - $title"
    fi
  done
  cat <<EOF


Generated notes
---------------

.. list-table::
   :widths: 20 40
   :header-rows: 1

   * - Key
     - Title
EOF
  for n in `echo $1|tr ' ' '\n'|sort -t/ -k4`; do
    f=`echo "$n"|cut -d/ -f2`
    if grep -i "^:Status:" "$f"|head -n 1|grep -q -i "Generated"; then
       k=`echo "$n"|cut -d/ -f1`
       title=`sed -n -e '2{p;q;}' <"$f"`
       echo "   * - [$k]_ |${k}h|_ |${k}p|_ |${k}t|_ |${k}x|_"
       echo "     - $title"
    fi
  done
  cat <<EOF
   * - \`\`index\`\`
     - Index of all notes (this document)


EOF
  IFS=$savec

}

do_header
do_catindex $catindex
do_cats $catindex "$keys"
do_chronindex "$keys"

# cat <<EOF

# Dependencies between notes
# ==========================

# .. image:: im/deps.png
#    :align: center

# EOF
