TEMPDIR=$1
TEXENV=$2
TEXFILE=$TEMPDIR/file.tex

sed -e "/@CONTENT@/$TEMPDIR/src.tex" -e "d}" "tex-environments/$TEXENV.tex" > $TEXFILE

pdflatex --output-directory $TEMPDIR $TEXFILE >$TEMPDIR/tex.log 2>$TEMPDIR/tex-err.log && \
    convert -density 300 -background white -alpha remove -quality 50 -colorspace RGB $TEMPDIR/file.pdf $TEMPDIR/file.png >$TEMPDIR/con.log 2>$TEMPDIR/con-err.log

RESULT=$?

{
    echo "===pdf2png stdout==="
    cat $TEMPDIR/con.log || echo "[empty]"

    echo "===pdf2png stderr==="
    cat $TEMPDIR/con-err.log || echo "[empty]"

    echo "===pdflatex stdout==="
    cat $TEMPDIR/tex.log || echo "[empty]"

    echo "===pdflatex stderr==="
    cat $TEMPDIR/tex-err.log || echo "[empty]"
} > $TEMPDIR/aggr.log

exit $RESULT