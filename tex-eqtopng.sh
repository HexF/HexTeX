#!/usr/bin/env bash

TEMPDIR=$(mktemp -d)
TEXFILE=$TEMPDIR/file.tex

cat <<END > $TEXFILE
\documentclass[border=2pt]{standalone}
\usepackage{amsmath}
\usepackage{varwidth}
\begin{document}
\begin{varwidth}{\linewidth}
\[
END

echo $QUERY_STRING | base64 -d >> $TEXFILE

cat <<END >> $TEXFILE
\]
\end{varwidth}
\end{document}
END

pdflatex --output-directory $TEMPDIR $TEXFILE > /dev/null

echo "Content-Type: image/png"
echo

convert -density 300 $TEMPDIR/file.pdf -quality 100 -colorspace RGB png:-

rm -rf $TEMPDIR


