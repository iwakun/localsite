#!/bin/bash
SITE_DIR=/home/chris/Documents/Websites/Local
APACHE_CONF_DIR=/etc/apache2

# Setup apache for local site
if [ "$1" == "-h" -o "$1" == "--help" ]
	then
		cat <<EOF
Usage: `basename $0` [--help] [<command> [<sitename>]]

Use the full site name (e.g., www.elikirk.com) for the <sitename>

Commands:
   list        List all the sites created by script
   install     Creates a directory, creates a apache.conf file, enables the
               site adds site to hosts file
			   Requires: <sitename>
   uninstall   Removes site from hosts file, disables site, deletes
               apache.conf file, removes directory
			   Requires: <sitename>
   disable     Comments out line in hosts file
               Requires: <sitename>
   enable      Un-comments line in hosts file
               Requires: <sitename>
EOF
	exit 1
fi

if [ $1 = "list" ]
	then
		echo "---------------------------------------------------------"
		echo "- Sites set up by localsite (sites with # are disabled) -"
		echo "---------------------------------------------------------"
		sed -n '/Custom Local Sites/,/END localsite/p' /etc/hosts | sed 's/\(#\)*[^ ]* /\1/' | tail -n +2 | head -n -1
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
		chown $SUDO_USER:$SUDO_USER $SITE_DIR/$SITE
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
        systemctl restart apache2

		echo "Adding $SITE to hosts file"
		LINE_NUMBER=`grep -n "Custom Local Sites" /etc/hosts | head -1 | cut -d: -f1`
		if [ -z $LINE_NUMBER ]
			then
				echo -e "### Custom Local Sites (added by localsite script) ###\n### END localsite sites ###" |
					tee --append /etc/hosts > /dev/null
		fi
		sed -i "s/### END/127.0.0.1 $SITE\n### END/" /etc/hosts
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
