#!/bin/bash

# Read settings from setup
. ../.env

echo "API URL: ${DATA_SERVER_URL}"
echo "User name: ${TESTUSER_NAME}"
echo "User API key: ${TESTUSER_KEY}"
echo "User ID: ${TESTUSER_ID}"

# API-key based checks:
echo -n "List user's items...      "
curl --fail-with-body --silent -H "Zotero-API-Key: ${TESTUSER_KEY}" "${DATA_SERVER_URL}/users/${TESTUSER_ID}/items"  >& /dev/null\
	&& echo "Success" || echo "Failed"

echo -n "List user's collections..."
curl --fail-with-body --silent -H "Zotero-API-Key: ${TESTUSER_KEY}" "${DATA_SERVER_URL}/users/${TESTUSER_ID}/collections?direction=desc&format=json&limit=100&sort=dateModified" >& /dev/null \
	&& echo "Success" || echo "Failed"

echo -n "Add new API key...        "
# Username/password based checks:
curl --fail-with-body --silent \
   -X POST \
   -H 'Content-Type: application/json' \
   -H 'Zotero-API-Version: 3' \
   -H 'Zotero-Schema-Version: 32' \
   -d "{ \"username\":\"${TESTUSER_NAME}\", \"password\":\"${TESTUSER_PASSWORD}\", \"name\":\"Automatic Zotero Client Key\", \"access\":{\"user\":{\"library\":true,\"notes\":true,\"write\":true,\"files\":true}, \"groups\":{\"all\":{\"library\":true,\"write\":true}}} }" \
    "${DATA_SERVER_URL}/keys" >& /dev/null \
    && echo "Success" || echo "Failed"

echo -n "Get default API key...    "
# Username/password based checks:
curl --fail-with-body --silent \
   -X POST \
   -H 'Content-Type: application/json' \
   -H 'Zotero-API-Version: 3' \
   -H 'Zotero-Schema-Version: 32' \
   -d "{ \"username\":\"${TESTUSER_NAME}\", \"password\":\"${TESTUSER_PASSWORD}\", \"name\":\"Automatic Zotero Client Key\" }" \
    "${DATA_SERVER_URL}/keys"  >& /dev/null \
    && echo "Success" || echo "Failed"
