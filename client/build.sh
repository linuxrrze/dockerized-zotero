#!/bin/bash

set -x
set -e

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

# Disable aws (connection) and ssh checks
sed -i s+'^which aws'+'#which aws'+ app/scripts/check_requirements
sed -i s+'^ssh '+'#ssh '+ app/scripts/check_requirements
sed -i s+'^aws '+'#aws '+ app/scripts/check_requirements
sed -i s+'^DEPLOY_CMD="ssh'+'DEPLOY_CMD="echo ssh'+ app/config.sh

"$BUILD_DIR/app/scripts/fetch_mar_tools"
"$BUILD_DIR/app/scripts/prepare_build" -s "$BUILD_DIR" -o /staging/build -c release -m $(./get_repo_branch_hash main)
"$BUILD_DIR/app/scripts/build_and_deploy" -s /staging/build -p $PLATFORM -c release
#"$BUILD_DIR/app/scripts/7.0_release_build_and_deploy"
#"$BUILD_DIR/app/scripts/dir_build" -q $PARAMS -p $PLATFORM

if [ "`uname`" = "Darwin" ]; then
	# Sign the Word dylib so it works on Apple Silicon
	"$BUILD_DIR/app/scripts/codesign_local" "$BUILD_DIR/app/staging/Zotero.app"
fi

cp -r -f $BUILD_DIR/app/staging/* /staging
