#!/bin/bash

# Configure
BUILD_DIR="/tmp/zotero"
ZOTERO_CONFIG_FILE="$BUILD_DIR/resource/config.js"
# Use GIT_BUILD_TAG if set
GIT_OPTIONS=${ZOTERO_CLIENT_GIT_BUILD_TAG:+--branch $ZOTERO_CLIENT_GIT_BUILD_TAG}
git clone ${GIT_OPTIONS} --recursive https://github.com/zotero/zotero "${BUILD_DIR}"

cd $BUILD_DIR

# Configure
sed -i "s#https://api.zotero.org/#$DATA_SERVER_ADDRESS/#g" $ZOTERO_CONFIG_FILE
sed -i "s#wss://stream.zotero.org/#$STREAM_SERVER_ADDRESS/#g" $ZOTERO_CONFIG_FILE
sed -i "s#https://zoteroproxycheck.s3.amazonaws.com/test##g" $ZOTERO_CONFIG_FILE
# sed -i "s#https://www.zotero.org/#$DATA_SERVER_ADDRESS/#g" $ZOTERO_CONFIG_FILE

# Install NodeJS Modules
npm install

# build
PARAMS=""
if [ "x$DEBUGGER" = "x1" ]; then
	PARAMS="-t"
fi

# run build watch # TEMP: --openssl-legacy-provider avoids a build error in pdf.js
NODE_OPTIONS=--openssl-legacy-provider npm run build

"$BUILD_DIR/app/scripts/dir_build" -q $PARAMS -p $PLATFORM

if [ "`uname`" = "Darwin" ]; then
	# Sign the Word dylib so it works on Apple Silicon
	"$BUILD_DIR/app/scripts/codesign_local" "$BUILD_DIR/app/staging/Zotero.app"
fi

cp -r -f $BUILD_DIR/app/staging/* /staging
