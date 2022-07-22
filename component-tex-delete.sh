echo -e "Content-Type: application/json"
echo "Status: 200 OK"
echo

# Defer the request
echo '{"type": 7}'

API_ENDPOINT="https://discord.com/api/v8"

# Now delete the message
curl -s -L -XDELETE "$API_ENDPOINT/webhooks/$(jq '.application_id' "$1" -r)/$(jq '.token' "$1" -r)/messages/$(jq '.message.id' "$1" -r)"