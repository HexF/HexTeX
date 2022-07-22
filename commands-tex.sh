#!/usr/bin/env bash

# We have a call!

BOUNDARY="boundary"
TEMPDIR=$(mktemp -d)
TEXFILE=$TEMPDIR/file.tex

putboundary(){
    echo -e "\r\n--${BOUNDARY}$1"
}

echo "Content-Type: multipart/form-data; boundary=$BOUNDARY"
echo "Status: 200 OK"
echo




cat <<END > $TEXFILE
\documentclass[border=2pt]{standalone}
\usepackage{amsmath}
\usepackage{amsfonts}
\usepackage{varwidth}
\begin{document}
\begin{varwidth}{\linewidth}
\[
END

jq '.data.options[] | select(.name=="latex").value' "$1" -r >> $TEXFILE

cat <<END >> $TEXFILE
\]
\end{varwidth}
\end{document}
END

pdflatex --output-directory $TEMPDIR $TEXFILE >$TEMPDIR/tex.log 2>$TEMPDIR/tex-err.log && \
    convert -density 300 -background white -alpha remove -quality 50 -colorspace RGB $TEMPDIR/file.pdf $TEMPDIR/file.png >$TEMPDIR/con.log 2>$TEMPDIR/con-err.log

if [ $? -eq 0 ]; then
    # Success! 
    
    # Send through the JSON
    putboundary
    echo 'Content-Disposition: form-data; name="payload_json"'
    echo "Content-Type: application/json"
    echo
    echo '{"type": 4, "data":{"embeds":[{"image":{"url":"attachment://tex.png"}}], "components":[{"type":2, "style":4,"label":"delete","custom_id":"tex-delete"}]}}'
    
    putboundary
    # Send through the image
    echo 'Content-Disposition: form-data; name="files[0]"; filename="tex.png"'
    echo "Content-Type: image/png"
    echo
    cat $TEMPDIR/file.png
    
    # Done
    putboundary "--"
else 
    putboundary
    echo 'Content-Disposition: form-data; name="payload_json"'
    echo "Content-Type: application/json"
    echo
    echo '{"type": 4, "data":{"embeds":[{"title":"Failed to Render"}], "attachments": [{"id":0, "description":"Error Logs", "filename":"error.log"}]}}'

    # Send through the logs
    putboundary
    echo 'Content-Disposition: form-data; name="files[0]"; filename="error.log"'
    echo "Content-Type: text/plain"
    echo

    echo "===pdf2png stdout==="
    cat $TEMPDIR/con.log || echo "[empty]"

    echo "===pdf2png stderr==="
    cat $TEMPDIR/con-err.log || echo "[empty]"

    echo "===pdflatex stdout==="
    cat $TEMPDIR/tex.log || echo "[empty]"

    echo "===pdflatex stderr==="
    cat $TEMPDIR/tex-err.log || echo "[empty]"

fi

putboundary "--"

rm -rf $TEMPDIR