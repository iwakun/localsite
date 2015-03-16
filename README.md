# localsite
Script to easily setup a local instances of websites. Also gives some tools to help manage the sites.

<h2>Installation</h2>
<h3>Linux</h3>
* Copy file to the directory of your choosing.
* Change line 3 to the appropriate values `SITE_DIR=/location/of/the/localsite.sh/file`
* Change line 2 if needed `APACHE_CONF_DIR=/etc/apache2`
* Link the file to your `/usr/bin` directory `sudo ln -s /<directory of file>/localsite.sh /usr/bin/localsite `

<h2>Usage</h2>

`sudo localsite [--help] [<command> [<sitename>]]`

Because we'll be editing the `/etc/hosts` file (among other things) this script needs to be run as root for every command except `list`

Use the full site name (e.g., www.elikirk.com) for the &lt;sitename&gt;

<h2>Commands</h2>
<h3>List</h3>
`localsite list`

Lists all the sites created by script

<h3>Install</h3>
`sudo localsite install <sitename>`

Does the following things:
* Creates a directory
* Creates an apache.conf file `<sitename>.conf`
* Enables the site using `a2ensite`
* Adds site to hosts file

<h3>Uninstall</h3>
`sudo localsite uninstall <sitename>`

Does the following things
* Removes site from hosts file
* Disables site using `a2dissite`
* Deletes apache.conf file
* Removes directory

<h3>Disable</h3>
`sudo localsite disable <sitename>`

Comments out line with &lt;sitename&gt; in hosts file

<h3>Enable</h3>
`sudo localsite enable <sitename>`

Un-comments line with &lt;sitename&gt; in hosts file
