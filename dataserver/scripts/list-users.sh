#!/bin/bash

MYSQL="mysql -h mysql -P 3306 -u root"

echo "# Users from zotero_master:"
echo "SELECT * from users;" | $MYSQL zotero_master

echo "# Users from zotero_www:"
echo "SELECT * from users;" | $MYSQL zotero_www

echo "# Users_email from zotero_www:"
echo "SELECT * from users_email;" | $MYSQL zotero_www

echo "# Merged user table:"
echo "SELECT users.userID, username, role, email FROM users JOIN users_email ON users.userID = users_email.userID;" | $MYSQL zotero_www
