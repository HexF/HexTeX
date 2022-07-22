#!/usr/bin/env bash

# We have a call!

BOUNDARY="boundary"
TEMPDIR=$(mktemp -d)
TEXFILE=$TEMPDIR/file.tex

echo "Content-Type: multipart/form-data; boundary=--$BOUNDARY"
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
    echo -e "\r"
    echo "--$BOUNDARY"
    echo 'Content-Disposition: form-data; name="payload_json"'
    echo "Content-Type: application/json"
    echo
    echo '{"type": 4, "data":{"embeds":[{"image":{"url":"attachment://tex.png"}}]}}'
    
    echo -e "\r"
    echo "--$BOUNDARY"
    # Send through the image
    echo 'Content-Disposition: form-data; name="files[0]"; filename="tex.png"'
    echo "Content-Type: image/png"
    echo
    cat $TEMPDIR/file.png
    
    # Done
    echo -e "\r"
    echo "--$BOUNDARY--"
else 
    echo -e "\r"
    echo "--$BOUNDARY"
    echo 'Content-Disposition: form-data; name="payload_json"'
    echo "Content-Type: application/json"
    echo
    echo '{"type": 4, "data":{"embeds":[{"title":"Failed to Render"}], "attachments": [{"id":0, "description":"pdf2png stdout", "filename":"con.log"},{"id":1, "description":"pdf2png stderr", "filename":"con-err.log"},{"id":2, "description":"pdflatex stdout", "filename":"tex.log"},{"id":3, "description":"pdflatex stderr", "filename":"tex-err.log"}]}}'

    # Send through the logs
    echo -e "\r"
    echo "--$BOUNDARY"
    echo 'Content-Disposition: form-data; name="files[0]"; filename="con.log"'
    echo "Content-Type: text/plain"
    echo
    cat $TEMPDIR/con.log || echo "[empty]"
    echo

    echo -e "\r"
    echo "--$BOUNDARY"
    echo 'Content-Disposition: form-data; name="files[1]"; filename="con-err.log"'
    echo "Content-Type: text/plain"
    echo
    cat $TEMPDIR/con-err.log || echo "[empty]"
    echo

    echo -e "\r"
    echo "--$BOUNDARY"
    echo 'Content-Disposition: form-data; name="files[2]"; filename="tex.log"'
    echo "Content-Type: text/plain"
    echo
    cat $TEMPDIR/tex.log || echo "[empty]"
    echo

    echo -e "\r"
    echo "--$BOUNDARY"
    echo 'Content-Disposition: form-data; name="files[3]"; filename="tex-err.log"'
    echo "Content-Type: text/plain"
    echo
    cat $TEMPDIR/tex-err.log || echo "[empty]"
    echo


    # Done
    echo -e "\r"
    echo "--$BOUNDARY--"
fi


rm -rf $TEMPDIR