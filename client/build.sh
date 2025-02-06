#!/bin/bash

set -x
set -e

# Configure
SOURCE_DIR="/tmp/zotero"
BUILD_DIR=$(mktemp -d)
ZOTERO_CONFIG_FILE="$SOURCE_DIR/resource/config.js"
# Use GIT_BUILD_TAG if set
GIT_BRANCH=${ZOTERO_CLIENT_GIT_BUILD_TAG:-main}
GIT_OPTIONS=${ZOTERO_CLIENT_GIT_BUILD_TAG:+--branch $ZOTERO_CLIENT_GIT_BUILD_TAG}
git clone ${GIT_OPTIONS} --recursive https://github.com/zotero/zotero "${SOURCE_DIR}"

cd "$SOURCE_DIR"
BRANCH_HASH=$(git log -n 1 --pretty=format:"%H")


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

# Change config
sed -i s+'^DEPLOY_PATH=.*'+'DEPLOY_PATH="/output/deploy"'+ "$SOURCE_DIR/app/config.sh"
cat "$SOURCE_DIR/app/config.sh"

sed -i s+'\$DEPLOY_HOST:'+''+ "$SOURCE_DIR/app/scripts/build_and_deploy"
#sed -i s+'scp '+'echo scp '+ "$SOURCE_DIR/app/scripts/build_and_deploy"
#sed -i -E s+'scp (.*) (.*)'+'test -f \1 \&\& cp \1 \2 || touch \2'+p "$SOURCE_DIR/app/scripts/build_and_deploy"
#sed -i -E s+'scp (.*) (.*)'+'test -f \1 \&\& cp \1 \2 || cat \2 \&\& echo [] > \2 \&\& cat \2'+p "$SOURCE_DIR/app/scripts/build_and_deploy"
for BUILD_ARCH in x86_64 i686; do
  JSONFILE=/output/deploy/release/updates-linux-${BUILD_ARCH}.json
  if [ ! -f "${JSONFILE}" ]; then
	echo '[]' > "${JSONFILE}"
  fi
done
sed -i -E s+'scp (.*) (.*)'+'cp \1 \2'+p "$SOURCE_DIR/app/scripts/build_and_deploy"

# Disable version_info for now
#sed -i -E s+'.*add_version_info.*'+'#\0'+ "$SOURCE_DIR/app/scripts/build_and_deploy"
cat "$SOURCE_DIR/app/scripts/build_and_deploy"

# Enable debug output
sed -i '2i set -x' "$SOURCE_DIR/app/scripts/build_and_deploy"
sed -i '2i set -x' "$SOURCE_DIR/app/scripts/upload_builds"
#sed -i s+'^aws '+'echo aws '+ "$SOURCE_DIR/app/scripts/upload_builds"

# New try
sed -i s+'^url=.*'+'url=/output/s3/client'+ "$SOURCE_DIR/app/scripts/upload_builds"
sed -i s+'^aws s3 sync '+'rsync '+ "$SOURCE_DIR/app/scripts/upload_builds"

# Disable scripts
sed -i '2i exit 0' "$SOURCE_DIR/app/scripts/manage_incrementals"

#rm -rf /output/deploy
mkdir -p /output/deploy/release
mkdir -p /output/s3/client

"$SOURCE_DIR/app/scripts/fetch_mar_tools"
"$SOURCE_DIR/app/scripts/prepare_build" -s "$SOURCE_DIR" -o ${BUILD_DIR} -c release -m "${BRANCH_HASH}"
"$SOURCE_DIR/app/scripts/build_and_deploy" -d ${BUILD_DIR} -p $PLATFORM -c release

#find .

if [ "`uname`" = "Darwin" ]; then
	# Sign the Word dylib so it works on Apple Silicon
	"$SOURCE_DIR/app/scripts/codesign_local" "$SOURCE_DIR/app/staging/Zotero.app"
fi

rsync -avx "$SOURCE_DIR"/app/dist/ /output/dist/
