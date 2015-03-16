# localsite
Script to easily setup a local instances of websites.

Usage: localsite [&45;&45;help] [&lt;command&gt; [&lt;sitename&gt;]]

Use the full site name (e.g., www.elikirk.com) for the &lt;sitename&gt;

Commands:
<ul>
   <li><strong>list</strong>: List all the sites created by script install     Creates a directory, creates a apache.conf file, enables the site adds site to hosts file <em>Requires: &lt;sitename&gt;</em></li>
   <li><strong>uninstall</strong>: Removes site from hosts file, disables site, deletes apache.conf file, removes directory <em>Requires: &lt;sitename&gt;</em></li>
   <li><strong>disable</strong>: Comments out line in hosts file <em>Requires: &lt;sitename&gt;</em></li>
   <li><strong>enable</strong>: Un-comments line in hosts file <em>Requires: &lt;sitename&gt;</em></li>
</ul>
