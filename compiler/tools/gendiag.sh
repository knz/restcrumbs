#! /bin/sh
# $Id: gendiag.sh 1049 2008-12-02 23:40:23Z kena $

set -e

cat <<EOF
digraph G {
  concentrate="true";
  rankdir="TB";
EOF
for d in "$@"; do
  ks=`basename $d .dep`
  for kd in `cat $d`; do
    echo "$kd -> $ks;"
  done
done
echo '}'



