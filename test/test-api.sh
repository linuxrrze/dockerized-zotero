#!/bin/bash

# zotero.org
API_KEY=SKvLFJ3pavlc4CAEFT5gYZUB
USERID=16126166
API_URL=https://api.zotero.org

# Self-hosted
. ../.env
API_KEY=${TESTUSER_KEY}
USERID=${TESTUSER_ID}
API_URL=${DATA_SERVER_URL}

curl -H "Zotero-API-Key: ${API_KEY}" "${API_URL}/users/${USERID}/items"
curl -H "Zotero-API-Key: ${API_KEY}" "${API_URL}/users/${USERID}/collections?direction=desc&format=json&limit=100&sort=dateModified"
