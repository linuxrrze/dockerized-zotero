#!/bin/bash

MYSQL="mysql -h mysql -P 3306 -u root"

#echo "SELECT username FROM users;" | $MYSQL zotero_master
#echo 'SELECT `key` FROM `keys`;' | $MYSQL zotero_master
echo 'SELECT keys.keyID, users.username, keys.key, keys.name, keys.dateAdded, keys.lastUsed FROM `users` JOIN `keys` ON users.userID = keys.userID;' | $MYSQL zotero_master
