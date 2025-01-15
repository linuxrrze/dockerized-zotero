#!/bin/bash

MYSQL="mysql -h mysql -P 3306 -u root"

if [ "x$1" == "x" ]; then
        echo "Syntax: ${0##*/} username"
        exit 1
fi

KEY=$(pwgen 24 1)
if [ "x$KEY" == "x" ]; then
	echo "Key generation failed - maybe pwgen missing?"
	exit 1
fi

userID=$(echo "SELECT userID FROM users WHERE username='${1}';" | $MYSQL zotero_master -s -N)
if [ "$userID" == "" ]; then
	echo "The user named ${1} does not exist."
	exit 1
fi

libraryID=$(echo "SELECT libraryID FROM users WHERE username='${1}';" | $MYSQL zotero_master -s -N)
if [ "$libraryID" == "" ]; then
	echo "No library ID found - aborting"
	exit 1
fi
echo "libraryID: $libraryID"

keyID=$(echo "INSERT INTO \`keys\` (\`key\`, userID, name) VALUES ('${KEY}', '${userID}', 'Automatic Zotero Client Key'); SELECT LAST_INSERT_ID()" | $MYSQL zotero_master -s -N)

echo "keyID: $keyID"

for PERMISSION in 'library' 'write'; do
	echo "INSERT INTO keyPermissions (keyID, libraryID, permission, granted) VALUES (${keyID},0,'${PERMISSION}',1)" | $MYSQL zotero_master
done
for PERMISSION in 'library' 'notes' 'write'; do
	echo "INSERT INTO keyPermissions (keyID, libraryID, permission, granted) VALUES (${keyID},${libraryID},'${PERMISSION}',1)" | $MYSQL zotero_master

done
