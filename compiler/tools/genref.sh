#! /bin/sh
spec=book$1.spec
key=book$1
glo=glo$1
shift 1
D=`dirname "$0"`
#CS="$D"/catsort.sh
#MD="$D"/makedep.sh

set -e

booktitle=`grep -i '^:Book:' <"$spec"|cut -d: -f3-`
color=`grep -i '^:Color:' <"$spec"|cut -d: -f3`
color=`echo $color`

cat <<EOF
\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$
 $booktitle
\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$

:Key: $key
:Color: $color
:Authors: Crumbs Collector
:Date: `date +%Y-%m-%d`
:Status: Generated
:Version: `date '+%Y-%m-%d %H:%M:%S'`
:Source: ``genref.sh``

.. contents::
   :depth: 4

EOF

SEDRULE=""
INS=`grep -i '^:Chapter:' <"$spec"|cut -d: -f3`
for i in $INS "$glo"; do
    f="$i".txt
    key=`grep -i '^:Key:' <"$f"|cut -d: -f3`
    key=`echo $key`
    title=`sed -n -e '2{p;q;}' <"$f"`
    title=`echo $title`
    SEDRULE="s|\[$key\]_|\`$title\`_|g;
$SEDRULE"
done
for i in $INS "$glo"; do
  #if test $i != "$glo"; then
    grep -v '^\.\. contents' <"$i".txt | sed -e "$SEDRULE"
  #fi
#   else
#     cat <<EOF
# ==========
#  Glossary
# ==========

# EOF
#     tail -n +4 <"$i".txt | grep -vi ':Status:' | sed -e "$SEDRULE"
#   fi
  echo
done




