# localsite
Script to easily setup a local instances of websites.

Usage: localsite [&45;&45;help] [&lt;command&gt; [&lt;sitename&gt;]]

Use the full site name (e.g., www.elikirk.com) for the &lt;sitename&gt;

Commands:
   list        List all the sites created by script
   install     Creates a directory, creates a apache.conf file, enables the
               site adds site to hosts file
               Requires: &lt;sitename&gt;
   uninstall   Removes site from hosts file, disables site, deletes 
               apache.conf file, removes directory
               Requires: &lt;sitename&gt;
   disable     Comments out line in hosts file
               Requires: &lt;sitename&gt;
   enable      Un-comments line in hosts file
               Requires: &lt;sitename&gt;
