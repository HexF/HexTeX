#!/usr/bin/env bash

# We have a call!

LATEX=$(jq '.data.options[] | select(.name=="latex").value' "$1" -r | base64 -w0)
PUBLIC_URL=$(dirname "$REQUEST_SCHEME://$SERVER_NAME$REQUEST_URI")

echo "Status: 200 OK"
echo

echo '{"type": 4, "data":{"embeds":[{"image":{"url":"'"$PUBLIC_URL/tex-eqtopng.sh?$LATEX"'"}}]}}'
