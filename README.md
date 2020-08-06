# localsite
Script to easily setup a local instances of websites. Also gives some tools to help manage the sites.

## Installation
### Linux
- Change line 3 to the appropriate values `SITE_DIR=/location/of/the/localsite.sh/file`
- Change line 2 if needed `APACHE_CONF_DIR=/etc/apache2`
- Link the file to your `/usr/local/bin` directory `sudo ln -s /directory/of/file/localsite.sh /usr/local/bin/localsite `
- (OPTIONAL) Link the helper scripts `wp_image_sync.sh` and `setup_wordpress_database.sh` to the `/usr/local/bin` directory
- (OPTIONAL) Copy the `localsite_completion` file to `/etc/bash_completion.d/` directory
- Install `mkcert` for using https (`https://github.com/FiloSottile/mkcert`)
	- Install the cert util `sudo apt install libnss3-tools`
	- Install go `sudo apt install golang-go`
	- Clone the mkcert repo `git clone https://github.com/FiloSottile/mkcert`
	- Compile `go build -ldflags "-X main.Version=$(git describe --tags)"`
	- Link the file `sudo ln -s /directory/of/file/mkcert /usr/local/bin/mkcert`
	- Run `mkcert -install`

## Usage

	sudo localsite [--help] [<command> [<sitename>]]

Because we'll be editing the `/etc/hosts` file (among other things) this script needs to be run as root for every command except `list`

Use the full site name (e.g., www.elikirk.com) for the &lt;sitename&gt;

## Commands
### List
	localsite list

Lists all the sites created by script

### Install
	sudo localsite install <sitename>`

Does the following things:
- Creates a directory `<sitename>`
- Creates a certificate/key pair and copies to `/etc/ssl/certs/`
- Creates an apache.conf file `<sitename>.conf`
- Enables the site using `a2ensite`
- Restarts apache
- Adds site to hosts file

### Uninstall
	sudo localsite uninstall <sitename>

Does the following things
- Removes site from hosts file
- Disables site using `a2dissite`
- Deletes apache.conf file
- Restarts apache
- Removes directory

### Disable
	sudo localsite disable <sitename>

Comments out line with &lt;sitename&gt; in hosts file

### Enable
	sudo localsite enable <sitename>

Un-comments line with &lt;sitename&gt; in hosts file
