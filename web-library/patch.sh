#!/bin/bash

. ../../.env

sed -i "s#apiAuthorityPart: 'api.zotero.org',#apiAuthorityPart: '${API_AUTHORITY_PART}',#" src/js/constants/defaults.js
sed -i "s#const websiteUrl = 'https://www.zotero.org/'#const websiteUrl = '${DATA_SERVER_URL}'#" src/js/constants/defaults.js
sed -i "s#const streamingApiUrl = 'wss://stream.zotero.org/'#const streamingApiUrl = '${STREAM_SERVER_ADDRESS}/'#" src/js/constants/defaults.js

sed -i "s#http://zotero.org/#${DATA_SERVER_URL}#" src/js/utils.js
sed -i "s#https?://zotero.org/#${DATA_SERVER_URL}#" src/js/utils.js
