#!/bin/bash
REMOTE_DIR=chris@elikirk-dev.com:/var/www/hosts

if [ -z "$1" ]
	then
		echo "Please provide a site name (remote directory)"
		exit 1
	else
		SITE=$1
fi

if [ ! -d "./wp-content/uploads" ]
	then
		echo "Please run this command from the Wordpress root directory"
		exit 1
fi

rsync -azP $REMOTE_DIR/$SITE/wp-content/uploads/ ./wp-content/uploads/
rsync -azP ./wp-content/uploads/ $REMOTE_DIR/$SITE/wp-content/uploads/
