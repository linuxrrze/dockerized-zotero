#!/bin/bash

MYSQL="mysql -h mysql -P 3306 -u root"

echo "# Libraries in zotero_master:"
echo 'SELECT * FROM libraries;' | $MYSQL zotero_master

echo "# Libraries in zotero_shard_1:"
echo 'SELECT * FROM shardLibraries;' | $MYSQL zotero_shard_1

echo "# Libraries in zotero_shard_2:"
echo 'SELECT * FROM shardLibraries;' | $MYSQL zotero_shard_2
