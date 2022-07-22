#!/usr/bin/env bash

check_signature(){
	local pub=$1
	local sig=$2
	local timestamp=$3
	local file=$4


	# Need a way to not use php here...
	echo $timestamp | cat - $file | tr -d '\n' | php verify.php $pub $sig 2> /dev/null

	if [[ $? -gt 0 ]]; then
		return 1
	else
		return 0
	fi
}

PUBLIC_KEY=$(jq .public_key credentials.json -r)

REQUEST_BODY=$(mktemp)
cat > "$REQUEST_BODY"

check_signature $PUBLIC_KEY $HTTP_X_SIGNATURE_ED25519 $HTTP_X_SIGNATURE_TIMESTAMP "$REQUEST_BODY"

if [[ $? -eq 1 ]]; then
	echo -e "Content-Type: application/json"
	echo "Status: 401 Unauthorized"
	echo

	echo '{"message":"Signature verification failed"}'
	exit 0
fi

REQ_TYPE=$(jq '.type' "$REQUEST_BODY" -r )

if [[ $REQ_TYPE -eq 1 ]]; then
	# Ping!
	echo -e "Content-Type: application/json"
	echo "Status: 200 OK"
	echo

	echo '{"type": 1}'
elif [[ $REQ_TYPE -eq 2 ]]; then
	# Interaction!

	bash commands-$(jq '.data.name' "$REQUEST_BODY" -r).sh "$REQUEST_BODY"
elif [[ $REQ_TYPE -eq 3 ]]; then
	bash component-$(jq '.data.custom_id' "$REQUEST_BODY" -r).sh "$REQUEST_BODY"
elif [[ $REQ_TYPE -eq 5 ]]; then
	bash modal-$(jq '.data.custom_id' "$REQUEST_BODY" -r).sh "$REQUEST_BODY"
fi


rm "$REQUEST_BODY"


