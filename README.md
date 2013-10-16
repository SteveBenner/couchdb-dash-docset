couchdb-dash-docset
===================
[Dash](http://kapeli.com/dash) is an excellent and amazing documentation and code snippet manager for Mac made by Bogdan Popescu of Kapeli

[Apache CouchDB](http://couchdb.apache.org/) is an open-source NoSQL database written in Erlang that uses an [HTTP API](http://docs.couchdb.org/en/latest/)

CouchDB documentation source was downloaded from: https://readthedocs.org/projects/couchdb/downloads/

Entry types and docset info are explained here: http://kapeli.com/docsets

# Inside
This repo contains a Ruby script that generates the Dash docset automatically in the default location based on the user's home path. After running it, all you should have to do is open Dash settings and 'rescan' to add the docset.

The script assumes the existence of Ruby gems `sqlite3`, `nokogiri`, and `plist`.

Included also is a `.tgz` archive containing the pre-built docset, which can be downloaded [here](https://github.com/SteveBenner/couchdb-dash-docset/blob/master/CouchDB-1.4.docset.tgz?raw=true)

## To Do (coming soon):
- A hosted Dash docset feed!
- Updated script for [CouchDB 1.5.x](http://docs.couchdb.org/en/latest/contents.html) which is in active development.

## Script notes
The basic premise is mapping the HTML documentation using Nokogiri, which is like jQuery for Ruby, in that it makes playing with the XML DOM fun and easy. Actually, a javascript version of this done in node.js would probably be more efficacious, but I'm a Rubyist first and foremost, and don't have experience with node.js yet.
