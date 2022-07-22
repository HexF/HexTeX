TEMPDIR=$1
TEXFILE=$TEMPDIR/file.tex


cat <<END > $TEXFILE
    \documentclass[border=2pt]{standalone}
    \usepackage{amsmath}
    \usepackage{amsfonts}
    \usepackage{varwidth}
    \begin{document}
    \begin{varwidth}{\linewidth}
    \[
END

cat $TEMPDIR/src.tex >> $TEXFILE

cat <<END >> $TEXFILE
\]
\end{varwidth}
\end{document}
END

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