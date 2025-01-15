#!/bin/bash

MYSQL="mysql -h mysql -P 3306 -u root"

if [ "x$1" = "x" ]; then
	echo "SELECT * FROM keyPermissions" | $MYSQL zotero_master
else
	echo "SELECT * FROM keyPermissions,\`keys\` WHERE keyPermissions.keyID=keys.keyID AND keys.key='${1}'" | $MYSQL zotero_master
fi
