#!/bin/bash

[ -n "${API_AUTHORITY_PART}" ] || exit 1
[ -n "${WEB_SERVER_URL}" ] || exit 1  
[ -n "${STREAM_SERVER_ADDRESS}" ] || exit 1
[ -n "${DATA_SERVER_URL}" ] || exit 1

# Configure
#git clone --recursive "https://github.com/zotero/web-components.git" "${SRC_DIR}/src"
git clone -b bootstrap4_integration --recursive "https://github.com/zotero/web-components.git" "${SRC_DIR}/src"
cd "${SRC_DIR}/src"
test -d ${SRC_DIR}/patches && for PATCH in ${SRC_DIR}/patches/*; do
	patch -p1 < $PATCH
done
npx --yes update-browserslist-db@latest
npm run build

test -d ${DST_DIR}/demo || mkdir -p ${DST_DIR}/demo
test -d ${DST_DIR}/build || mkdir -p ${DST_DIR}/build
test -d ${DST_DIR}/assets || mkdir -p ${DST_DIR}/assets

cp -r -f "${SRC_DIR}"/src/demo/* ${DST_DIR}/demo
cp -r -f "${SRC_DIR}"/src//build/* ${DST_DIR}/build
cp -r -f "${SRC_DIR}"/src/assets/* ${DST_DIR}/assets
