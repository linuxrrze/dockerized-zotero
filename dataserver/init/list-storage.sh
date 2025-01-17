#!/bin/bash

MYSQL="mysql -h mysql -P 3306 -u root"

echo "# List storageAccounts:"
echo "SELECT * from storageAccounts;" | $MYSQL zotero_master

echo "# List storageFileLibraries:"
echo "SELECT * from storageFileLibraries;" | $MYSQL zotero_master

echo "# List storageFiles:"
echo "SELECT * from storageFiles;" | $MYSQL zotero_master
