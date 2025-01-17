#!/bin/bash

MYSQL="mysql -h mysql -P 3306 -u root"

echo "# Libraries in zotero_master:"
echo 'SELECT * FROM libraries;' | $MYSQL zotero_master

echo "# Libraries in zotero_shard_1:"
echo 'SELECT * FROM shardLibraries;' | $MYSQL zotero_shard_1

echo "# Libraries in zotero_shard_2:"
echo 'SELECT * FROM shardLibraries;' | $MYSQL zotero_shard_2

echo "# List all libraries:"
echo   '(SELECT libraryID,libraryType,lastUpdated,version,storageUsage FROM zotero_shard_1.shardLibraries)
	UNION
	(SELECT libraryID,libraryType,lastUpdated,version,storageUsage FROM zotero_shard_2.shardLibraries)
	ORDER BY libraryID;' | $MYSQL

echo "# List all user libraries (zotero_shard_1):"
echo   'SELECT * FROM zotero_shard_1.shardLibraries AS shardLibs, zotero_master.users AS us
	WHERE shardLibs.libraryID = us.libraryID
	ORDER BY us.libraryID;' | $MYSQL

echo "# List all group libraries (zotero_shard_2):"
echo   'SELECT * FROM zotero_shard_2.shardLibraries AS shardLibs, zotero_master.groups AS gr
	WHERE shardLibs.libraryID = gr.libraryID
	ORDER BY gr.libraryID;' | $MYSQL
