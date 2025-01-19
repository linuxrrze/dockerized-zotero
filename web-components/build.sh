#!/bin/bash

[ -n "${API_AUTHORITY_PART}" ] || exit 1
[ -n "${WEB_SERVER_URL}" ] || exit 1  
[ -n "${STREAM_SERVER_ADDRESS}" ] || exit 1
[ -n "${DATA_SERVER_URL}" ] || exit 1

# Configure
BUILD_DIR=/tmp/build
rm -rf "${BUILD_DIR}"
git clone -b bootstrap4_integration --recursive "https://github.com/zotero/web-components.git" "${BUILD_DIR}"
cd "${BUILD_DIR}"
test -d ${SRC_DIR}/patches && for PATCH in ${SRC_DIR}/patches/*; do
	patch -p1 < $PATCH
done
npx --yes update-browserslist-db@latest
npm run build

test -d ${DST_DIR}/build || mkdir -p ${DST_DIR}/build
test -d ${DST_DIR}/assets || mkdir -p ${DST_DIR}/assets

cp -r "${BUILD_DIR}"/demo/* ${DST_DIR}/
cat "${BUILD_DIR}"/demo/index.html | sed -e s+/demo/+/+ > ${DST_DIR}/index-demo.html
cp -rf "${BUILD_DIR}"/build/* ${DST_DIR}/build/
cp -rf "${BUILD_DIR}"/assets/* ${DST_DIR}/assets/
