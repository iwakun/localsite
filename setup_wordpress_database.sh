#!/bin/bash
FILE=wp-config.php

if [ "$EUID" -ne 0 ]
	then echo "Please run with sudo"
	exit 1
fi

if [ -f "$FILE" ]; then
	echo "wp-config.php file found"

	DB_NAME=`cat wp-config.php | grep DB_NAME | cut -d \' -f 4`
	DB_USER=`cat wp-config.php | grep DB_USER | cut -d \' -f 4`
	DB_PASSWORD=`cat wp-config.php | grep DB_PASSWORD | cut -d \' -f 4`

	echo "DB_NAME: $DB_NAME"
	echo "DB_USER: $DB_USER"
	echo "DB_PASSWORD: $DB_PASSWORD"

	mysql --execute "CREATE DATABASE IF NOT EXISTS $DB_NAME"
	echo "Database $DB_NAME created"

	mysql --execute "GRANT ALL ON $DB_NAME.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD'"
	echo "Database access for $DB_USER created"

	echo "Mysql database setup for $DB_NAME"
else
	echo "Please run in the same directory as wp-config.php"
	exit 1
fi
