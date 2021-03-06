TEMPDIR=$(mktemp -d)
TEXFILE=$TEMPDIR/file.tex
BOUNDARY="boundary"
putboundary(){
    echo -e "\r\n--${BOUNDARY}$1"
}

echo "Content-Type: multipart/form-data; boundary=$BOUNDARY"
echo "Status: 200 OK"
echo

jq '.data.components[] | select(.components[0].custom_id=="latex").components[0].value' "$1" -r >> $TEMPDIR/src.tex

bash latex-render.sh "$TEMPDIR" "$(jq '.data.components[] | select(.components[0].custom_id=="texenv").components[0].values[0]' "$1" -r)"

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

    cat $TEMPDIR/aggr.log
fi


putboundary "--"

rm -rf $TEMPDIR