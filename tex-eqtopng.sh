#!/usr/bin/env bash

TEMPDIR=$(mktemp -d)
TEXFILE=$TEMPDIR/file.tex

echo $QUERY_STRING | base64 -d >> $TEMPDIR/src.tex

bash latex-render.sh "$TEMPDIR"

echo "Content-Type: image/png"
echo

cat $TEMPDIR/file.png

rm -rf $TEMPDIR


