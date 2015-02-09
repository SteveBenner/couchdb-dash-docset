# CouchDB docset for Dash
[Dash](http://kapeli.com/dash) is an excellent and amazing documentation and code snippet manager for Mac made by Bogdan Popescu of Kapeli

[Apache CouchDB](http://couchdb.apache.org/) is an open-source NoSQL database written in Erlang that uses an [HTTP API](http://docs.couchdb.org/en/latest/)

CouchDB documentation source was downloaded from: https://readthedocs.org/projects/couchdb/downloads/

Entry types and docset info are explained here: http://kapeli.com/docsets

## Installation
1. Install gems needed by the script with `bundle install` (**skip this step if gems already available**)
2. Run the script `docset-gen`, which creates the Docset and automatically installs it for the current user.
3. Open Dash, and under the 'Docsets' tab click the 'rescan' button to load the CouchDB docset.

**OR**

Download and extract [the included archive](https://github.com/SteveBenner/couchdb-dash-docset/blob/master/CouchDB-1.4.docset.tgz?raw=true) containing the pre-built Docset, and just open it.

#### Developer notes
The process I used in my script is one of parsing the prebuilt HTML docs into the data necessary for a quality Dash Docset. As my foremost expertise is in Ruby, I used [Nokogiri](http://nokogiri.org/) to accomplish this, and I found it to be similar jQuery in that it makes playing with the XML DOM **incredibly fun and easy**. Reflecting on this, it's possible the same goal might be achieved in a more elegant fashion using something like Node.js; in the future I may switch over to pure JS to find out.

---
### NOTICE: The documentation this Docset provides is outdated!
CouchDB is currently on version 1.6--the latest docs for which can be found [here](http://docs.couchdb.org/en/1.6.1/).

**I do intend to update this repository and contribute Docsets for the latest versions of CouchDB at some point, but I can't say when.**