#!/bin/bash

set -x
set -e

[ -n "${API_AUTHORITY_PART}" ] || exit 1
[ -n "${WEB_SERVER_URL}" ] || exit 1  
[ -n "${STREAM_SERVER_ADDRESS}" ] || exit 1
[ -n "${DATA_SERVER_URL}" ] || exit 1

node -v
npm -v

# Configure
BUILD_DIR=/tmp/build
# Use GIT_BUILD_TAG if set
GIT_OPTIONS=${GIT_BUILD_TAG:+--branch $GIT_BUILD_TAG}
rm -rf "${BUILD_DIR}"
git clone ${GIT_OPTIONS} --recursive "https://github.com/zotero/web-library.git" "${BUILD_DIR}"
cd "${BUILD_DIR}"
for PATCH in ${SRC_DIR}/patches/*.patch; do
	patch -p1 < $PATCH
done

sed -i s#"apiAuthorityPart:.*$"#"apiAuthorityPart: '${API_AUTHORITY_PART}',"# src/js/constants/defaults.js
sed -i s#"export const websiteUrl =.*$"#"export const websiteUrl = '${WEB_SERVER_URL}';"# src/js/constants/defaults.js
sed -i s#"export const streamingApiUrl =.*$"#"export const streamingApiUrl = '${STREAM_SERVER_ADDRESS}';"# src/js/constants/defaults.js
cat src/js/constants/defaults.js

sed -i s#"http://zotero.org/"#"${DATA_SERVER_URL}"# src/js/utils.js
sed -i s#"https?://zotero.org/"#"${DATA_SERVER_URL}"# src/js/utils.js
cat src/js/utils.js

npm install
npm run build

cp -rf "${BUILD_DIR}"/build/* ${DST_DIR}
cp -rf "${SRC_DIR}"/html/* ${DST_DIR}
