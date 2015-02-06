# CouchDB docset for Dash
[Dash](http://kapeli.com/dash) is an excellent and amazing documentation and code snippet manager for Mac made by Bogdan Popescu of Kapeli

[Apache CouchDB](http://couchdb.apache.org/) is an open-source NoSQL database written in Erlang that uses an [HTTP API](http://docs.couchdb.org/en/latest/)

CouchDB documentation source was downloaded from: https://readthedocs.org/projects/couchdb/downloads/

Entry types and docset info are explained here: http://kapeli.com/docsets

## Installation
1. Install gems needed by the script with `bundle install` (**skip this step if already available**)
2. Run the script `generator`, which creates the Docset and automatically installs it for the current user.
3. Open Dash, and under the 'Docsets' tab click the 'rescan' button to load the CouchDB docset.

**OR**

Download and extract [the included archive](https://github.com/SteveBenner/couchdb-dash-docset/blob/master/CouchDB-1.4.docset.tgz?raw=true) containing the pre-built Docset, and just open it.

#### Developer notes
The basic premise is mapping the HTML documentation using Nokogiri, which is like jQuery for Ruby, in that it makes playing with the XML DOM fun and easy. Actually, a javascript version of this done in node.js would probably be more efficacious, but I'm a Rubyist first and foremost, and don't have experience with node.js yet.

---
### NOTICE: The documentation this Docset provides is outdated!
CouchDB is currently on version 1.6; the latest docs can be found [here](http://docs.couchdb.org/en/1.6.1/).

**I intend to update this repository and contribute Docsets for the latest versions of CouchDB at some point, but I can't say when.**