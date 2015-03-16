# localsite
Script to easily setup a local instances of websites.

Usage: localsite [--help] [<command> [<sitename>]]

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
