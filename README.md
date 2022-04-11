# Dash Docset for Apache CouchDB 1.4

[Dash](http://kapeli.com/dash) is an excellent and amazing documentation and code snippet manager for Mac made by Bogdan Popescu of Kapeli

[Apache CouchDB](http://couchdb.apache.org/) is an open-source NoSQL database written in Erlang that uses an [HTTP API](http://docs.couchdb.org/en/latest/)

CouchDB documentation source was downloaded from: https://readthedocs.org/projects/couchdb/downloads/

Entry types and Docset info is explained here: http://kapeli.com/docsets

## Generation / Installation
1. The generator script is dependent upon gems `sqlite3`, `nokogiri`, and `plist`. **If you already have them installed on your system, you can skip this step**. Otherwise, run `bundle install`.
2. Run the script `docset-gen` to create the Docset and automatically install it for the current user.
3. Open Dash, and under the 'Docsets' tab click the 'rescan' button to load the CouchDB docset.

**OR**

Download and extract [the included archive](https://github.com/SteveBenner/couchdb-dash-docset/blob/master/CouchDB-1.4.docset.tgz?raw=true) containing the pre-built Docset, and just open it.

---

#### Development notes
The process I used in my script is one of parsing the prebuilt HTML docs into the data necessary for a quality Dash Docset. As my foremost expertise is in Ruby, I used [Nokogiri](http://nokogiri.org/) to accomplish this, and I found it to be similar jQuery in that it makes playing with the XML DOM **incredibly fun and easy**. Reflecting on this, it's possible the same goal might be achieved in a more elegant fashion using something like Node.js; in the future I may switch over to pure JS to find out.
