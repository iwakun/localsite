#!/bin/bash
SITE_DIR=/home/chris/Programming
APACHE_CONF_DIR=/etc/apache2
DEFAULTUSER=chris

# Setup apache for local site
if [ "$1" == "-h" -o "$1" == "--help" ]
	then
		cat <<EOF
Usage: `basename $0` [--help] [<command> [<sitename>]]

Use the full site name (e.g., www.elikirk.com) for the <sitename>

Flags:
   s           Also set up https

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
   perms       Sets ownership to apache_user:apache_user with user and
               group RWX permissions set
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
		sudo -u $DEFAULTUSER mkcert $SITE
		mv $SITE.pem $SITE-key.pem /etc/ssl/certs/
		echo -e "Making directory in $SITE_DIR/$SITE\n"
		mkdir $SITE_DIR/$SITE
		chown $SUDO_USER:$SUDO_USER $SITE_DIR/$SITE
		chmod 775 $SITE_DIR/$SITE

		echo -e "Writing apache.conf file\n"
		touch $APACHE_CONF_DIR/sites-available/${SITE}.conf

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

<VirtualHost *:443>
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
	SSLEngine on
	SSLOptions +StrictRequire
	SSLCertificateFile /etc/ssl/certs/$SITE.pem
	SSLCertificateKeyFile /etc/ssl/certs/$SITE-key.pem
</VirtualHost>
EOF

		echo -e "Configuring $SITE with a2ensite\n"
		a2ensite $SITE

		echo -e "Restarting Apache\n"
        systemctl restart apache2

		echo -e "Adding $SITE to hosts file\n"
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
		echo -e "Disabling $SITE with a2dissite\n"
		a2dissite $SITE

		echo -e "Removing $SITE from hosts file\n"
		sed -i "/$SITE/d" /etc/hosts

		echo -e "Deleting $SITE certs\n"
		rm /etc/ssl/certs/${SITE}.pem /etc/ssl/certs/${SITE}-key.pem

		echo -e "Deleting $SITE apache.conf file\n"
		rm $APACHE_CONF_DIR/sites-available/${SITE}.conf

		echo -e "Deleting folder for $SITE\n"
		rm -rf $SITE_DIR/$SITE

		echo "$SITE removed"
		exit 1
fi

if [ $1 = "disable" ]
	then
		echo -e "Disabling $SITE\n"
		LINE_NUMBER=`grep -n "$SITE" /etc/hosts | head -1 | cut -d: -f1`
		sed -i "$LINE_NUMBER s/^\(.*\)$/#\\1/" /etc/hosts
		echo "/etc/hosts:$LINE_NUMBER `sed -n "${LINE_NUMBER}p" /etc/hosts`"
		exit 1
fi

if [ $1 = "enable" ]
	then
		echo -e "Enabling $SITE\n"
		LINE_NUMBER=`grep -n "$SITE" /etc/hosts | head -1 | cut -d: -f1`
		cat /etc/hosts | sed -i "$LINE_NUMBER s/^#//" /etc/hosts
		echo "/etc/hosts:$LINE_NUMBER `sed -n "${LINE_NUMBER}p" /etc/hosts`"
		exit 1
fi

if [ $1 = "perms" ]
	then
		echo -e "Setting up permissions for $SITE\n"
		APACHE_USER=$(ps axho user,comm|grep -E "httpd|apache|www-data"|uniq|grep -v "root"|awk 'END {if ($1) print $1}')
		echo -e "Apache user found: $APACHE_USER\n"
		chown -R $APACHE_USER:$APACHE_USER $SITE_DIR/$SITE
		chmod -R 775 $SITE_DIR/$SITE
		echo "Permissions set for $SITE"
		exit 1
fi

echo "Invalid option"
