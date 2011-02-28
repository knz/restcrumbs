#! /bin/bash
# $Id: rebuild.sh 4169 2010-11-26 15:52:43Z kena $
set -e 
PATH=$HOME/custom-python/bin:$PATH:/usr/local/bin
export PATH
LANG=en.iso-8859-1
export LANG
D=`dirname "$0"`
cd "$D"
umask 022
if test "$1" = "True"; then
   echo "Cleaning up..."
   make purge
fi
echo "Building everything..."
#make -j2 -W book0.spec
make -j2 web 
echo "Populating the web directory..."
rsync -av --delete www/* ../www-publish/
cat >../www-publish/robots.txt <<EOF
User-agent: *
Disallow: /
EOF
echo "Done."
