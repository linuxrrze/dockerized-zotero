#!/bin/sh

MYSQL_HOST=mysql
MYSQLDUMP="mysqldump -h ${MYSQL_HOST} -P 3306 -u root"

if [ "x$1" = "x" ]; then
	$MYSQLDUMP --all-databases
else
	$MYSQLDUMP "$1"
fi
