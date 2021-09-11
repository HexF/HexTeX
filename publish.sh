#!/usr/bin/env bash

API_ENDPOINT="https://discord.com/api/v8"

CLIENT_ID=$(jq '.client_id' credentials.json -r)
CLIENT_SECRET=$(jq '.client_secret' credentials.json -r)

curl -XPOST $API_ENDPOINT"/oauth2/token" \
	-d 'grant_type=client_credentials' \
	-d 'scope=applications.commands.update' \
	-u "$CLIENT_ID:$CLIENT_SECRET" > creds.tmp.json

AUTH_HEADER=$(jq '.token_type + " " + .access_token' creds.tmp.json -r)

rm creds.tmp.json

publish_command(){
	local command_spec=$1
	curl -XPOST $API_ENDPOINT"/applications/$CLIENT_ID/commands" \
	        -d "@$command_spec" \
                -H 'Content-Type: application/json' \
                -H "Authorization: $AUTH_HEADER" | jq
}

for cmd_spec in ./commands-*.json; do
	publish_command $cmd_spec
done

