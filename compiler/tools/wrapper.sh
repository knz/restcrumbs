#! /bin/sh
# $Id: wrapper.sh 4111 2010-11-09 10:28:59Z kena $
# This script is a wrapper around commands that
# transform reStructured Text to other formats.
# It is able to "find" the right commands in the
# environment, even when they have different names.
# The following substitutions are known:
#   rst2html -> rst2html.py 
#   rst2latex -> rst2latex.py
#   rst2s5 -> rst2s5.py
#   pdflatex -> latex + dvipdf
#   dvipdf -> dvipdfm
#   dvipdf -> dvipdfmx
#   dvipdf -> dvips + gs
#   dot2png -> dot
#   dot2png -> dot2tex + pdflatex + pdf2png
#   pdf2png -> convert

set -e

CMD=$1
shift

case "$CMD" in
 rst2html|rst2latex|rst2s5)
   if "$CMD"-highlight --version >/dev/null 2>&1; then
      exec "$CMD"-highlight "$@" 
   elif "$CMD" --version >/dev/null 2>&1; then
      exec "$CMD" "$@" 
   elif "$CMD".py --version >/dev/null 2>&1; then
      echo "(using $CMD.py for $CMD...)"
      exec "$CMD".py "$@"
   else
      echo "Program $CMD not found in PATH and no substitute available."
      exit 1
   fi
   ;;
 pdflatex)
   LTX=`basename "$1"`
   DIR=`dirname "$1"`
   BASE=`expr "$LTX" : '\(.*\)\.[^.]*'`
   cd "$DIR"
   if "$CMD" -version >/dev/null 2>&1; then
      "$CMD" -halt-on-error "$LTX" >/dev/null 2>&1 && \
      "$CMD" -halt-on-error "$LTX" >/dev/null 2>&1
      exit $?
   elif latex -version >/dev/null 2>&1; then 
      echo "Using LaTeX + dvipdf for $CMD..."
      latex -halt-on-error "$LTX" >/dev/null 2>&1 && \
      latex -halt-on-error "$LTX" >/dev/null 2>&1 && \
      "$0" dvipdf "$BASE".dvi "$BASE".pdf
      exit $?
   elif texi2pdf --version >/dev/null 2>&1; then
      echo "(using texi2pdf for $CMD...)"
      exec texi2pdf "$LTX"
   else
      echo "Program $CMD not found in PATH and no substitute available."
      exit 1
   fi
   ;;      

 dvipdf)
   IN=$1
   OUT=$2
   if dvipdfmx --help >/dev/null 2>&1; then
      echo "(using dvipdfmx for $CMD...)"
      exec dvipdfmx "$IN" >"$OUT"
   elif dvipdfm --help >/dev/null 2>&1; then
      echo "(using dvipdfm for $CMD...)"
      exec dvipdfm "$IN" >"$OUT"
   elif "$CMD" --help >/dev/null 2>&1; then
      exec dvipdf "$IN" >"$OUT"
   elif dvips --help >/dev/null 2>&1 && gs --help >/dev/null 2>&1; then
      echo "(using dvips + gs for $CMD...)"
      dvips "$IN" >"$IN".ps && \
      gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite "$IN".ps >"$OUT"
      exit $?
   else
      echo "Program $CMD not found in PATH and no substitute available."
      exit 1
   fi
   ;;
 dot2png)
   IN=$1
   OUT=$2
   BASE=`expr "$IN" : '\(.*\)\.[^.]*'`
   if dot2tex --help >/dev/null 2>&1; then
      echo "(using dot2tex + pdflatex + pdf2png for $CMD...)"
      dot2tex "$IN" >"$BASE".tex && \
      "$0" pdflatex "$BASE".tex && \
      "$0" pdf2png "$BASE".pdf "$OUT"
      exit $?
   elif dot </dev/null >/dev/null 2>&1; then
      echo "(using dot for $CMD...)"
      exec dot -Tpng -o "$OUT" "$IN"
   else
      echo "Program $CMD not found in PATH and no substitute available."
      exit 1
   fi
   ;;
 pdf2png)
   IN=$1
   OUT=$2
   if convert --help >/dev/null 2>&1; then
      echo "(using convert for $CMD...)"
      exec convert "$IN" -trim "$OUT"
   else
      echo "Program $CMD not found in PATH and no substitute available."
      exit 1
   fi
   ;;            
esac
