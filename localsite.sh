#!/bin/bash
SITE_DIR=/home/chris/Documents/Websites/Local
APACHE_CONF_DIR=/etc/apache2

# Setup apache for local site
if [ "$1" == "-h" -o "$1" == "--help" ]
	then 
		cat <<EOF 
Usage: `basename $0` [--help] <command> <sitename>

Use the full site name (e.g., www.elikirk.com) for the <sitename>

Commands:
   install     Creates a directory, creates a apache.conf file, enables the
               site adds site to hosts file
   uninstall   Removes site from hosts file, disables site, deletes 
               apache.conf file, removes directory
   disable     Comments out line in hosts file
   enable      Un-comments line in hosts file
EOF
	exit 1
fi

if [ "$EUID" -ne 0 ]
	then echo "Please run with sudo"
	exit 1
fi

if [ -z "$2" ]
	then 
		echo "Please provide a site name"
		exit 1
	else
		SITE=$2
fi

if [ $1 = "install" ]
	then
		echo "Making directory in $SITE_DIR/$SITE"
		mkdir $SITE_DIR/$SITE
		chown $USER:$USER $SITE_DIR/$SITE
		chmod 775 $SITE_DIR/$SITE

		echo "Writing apache.conf file"
		cat <<EOF > $APACHE_CONF_DIR/sites-available/${SITE}.conf
<VirtualHost *:80>
	ServerName $SITE
	DocumentRoot $SITE_DIR/$SITE
	ErrorLog \${APACHE_LOG_DIR}/error.log
	CustomLog \${APACHE_LOG_DIR}/access.log combined
	<Directory $SITE_DIR/$SITE>
		DirectoryIndex index.html index.php
		AllowOverride All
		Order allow,deny
		Allow from all
		Require all granted
	</Directory>
</VirtualHost>
EOF
		echo "Configuring $SITE with a2ensite"
		a2ensite $SITE
		
		echo "Restarting Apache"
		service apache2 restart
		
		echo "Adding $SITE to hosts file"
		echo "127.0.0.1 $SITE" | tee --append /etc/hosts > /dev/null
		exit 1
fi

if [ $1 = "uninstall" ]
	then
		echo "Disabling $SITE with a2dissite"
		a2dissite $SITE

		echo "Removing $SITE from hosts file"
		sed -i "/$SITE/d" /etc/hosts

		echo "Deleting $SITE apache.conf file"
		rm $APACHE_CONF_DIR/sites-available/${SITE}.conf
		
		echo "Deleting folder for $SITE"
		rm -rf $SITE_DIR/$SITE

		echo "$SITE removed"
		exit 1
fi

if [ $1 = "disable" ]
	then
		echo "Disabling $SITE"
		LINE_NUMBER=`grep -n "$SITE" /etc/hosts | head -1 | cut -d: -f1`
		sed -i "$LINE_NUMBER s/^\(.*\)$/#\\1/" /etc/hosts
		echo "/etc/hosts:$LINE_NUMBER `sed -n "${LINE_NUMBER}p" /etc/hosts`"
		exit 1
fi

if [ $1 = "enable" ]
	then
		echo "Enabling $SITE"
		LINE_NUMBER=`grep -n "$SITE" /etc/hosts | head -1 | cut -d: -f1`
		cat /etc/hosts | sed -i "$LINE_NUMBER s/^#//" /etc/hosts
		echo "/etc/hosts:$LINE_NUMBER `sed -n "${LINE_NUMBER}p" /etc/hosts`"
		exit 1
fi

echo "Invalid option"
