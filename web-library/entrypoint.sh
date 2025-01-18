#!/bin/bash

ROOT_DIR="/zotero-web-library"

test -d $ROOT_DIR || mkdir -p $ROOT_DIR
cd $ROOT_DIR

# Configure
git clone --recursive "https://github.com/zotero/web-library.git" "${ROOT_DIR}"
cd "${ROOT_DIR}"
for PATCH in /patches/*; do
	patch -p1 < $PATCH
done
npm ci && npm cache clean --force
npm run build

cp -rf "${ROOT_DIR}"/build/* /build
test -d /html && cp -rf /html/* /build
