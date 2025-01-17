#!/bin/bash

ROOT_DIR="/zotero-web-components"

test -d $ROOT_DIR || mkdir -p $ROOT_DIR
cd $ROOT_DIR

# Configure
git clone --recursive "https://github.com/zotero/web-components.git" "${ROOT_DIR}"
cd "${ROOT_DIR}"
test -d /patches && for PATCH in /patches/*; do
	patch -p1 < $PATCH
done
npx --yes update-browserslist-db@latest
npm run build

test -d /build/demo || mkdir -p /build/demo
test -d /build/build || mkdir -p /build/build
test -d /build/assets || mkdir -p /build/assets

cp -r -f "${ROOT_DIR}"/demo/* /build/demo
cp -r -f "${ROOT_DIR}"/build/* /build/build
cp -r -f "${ROOT_DIR}"/assets/* /build/assets

