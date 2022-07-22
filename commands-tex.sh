#!/usr/bin/env bash

# We have a call!

BOUNDARY="boundary"
TEMPDIR=$(mktemp -d)


API_ENDPOINT="https://discord.com/api/v8"
TOKEN=$(jq '.token' "$1" -r)

OPTION_LENGTH=$(jq '.data.options | length' "$1" -r )

putboundary(){
    echo -e "\r\n--${BOUNDARY}$1"
}

echo "Content-Type: multipart/form-data; boundary=$BOUNDARY"
echo "Status: 200 OK"
echo

if [[ $OPTION_LENGTH -eq 0 ]]; then
    # Launch a modal
    putboundary
    echo 'Content-Disposition: form-data; name="payload_json"'
    echo "Content-Type: application/json"
    echo
    echo -n '{"type": 9, "data":{"custom_id": "tex-render", "title": "Render LaTeX w/ HeXTeX", "components": ['
    echo -n '{"type": 4, "custom_id": "latex", "style": 2, "label":"LaTeX Code"}'
    echo ']}}'
else

    jq '.data.options[] | select(.name=="latex").value' "$1" -r >> $TEMPDIR/src.tex

    bash latex-render.sh "$TEMPDIR"

    if [ $? -eq 0 ]; then
        # Success! 
        
        # Send through the JSON
        putboundary
        echo 'Content-Disposition: form-data; name="payload_json"'
        echo "Content-Type: application/json"
        echo
        echo '{"type": 4, "data":{"embeds":[{"image":{"url":"attachment://tex.png"}}]}}'
        
        putboundary
        # Send through the image
        echo 'Content-Disposition: form-data; name="files[0]"; filename="tex.png"'
        echo "Content-Type: image/png"
        echo
        cat $TEMPDIR/file.png

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
fi

putboundary "--"

rm -rf $TEMPDIR