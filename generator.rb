#!/usr/bin/env ruby

# Dash docset generator for Apache CouchDB 1.4
# This is simply a tool for generating Dash docsets from HTML documentation of any kind. It is configured for CouchDB.

# LICENSE:
# Copyright (C) 2013 Stephen C. Benner
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'fileutils'
require 'open-uri' # built-in Ruby module that encapsulates an HTTP request within the 'open' command
require 'sqlite3'
require 'nokogiri' # awesome XML/HTML parser
require 'plist'    # manipulate Dash docset info

# "Dash" is an amazing documentation and code snippet manager by Bogdan Popescu of Kapeli
# http://kapeli.com/dash

# "Apache CouchDB" is an open-source NoSQL database written in Erlang that uses an HTTP API
# http://couchdb.apache.org/
# http://docs.couchdb.org/en/latest/

# CouchDB documentation source was downloaded from: https://readthedocs.org/projects/couchdb/downloads/

# Latest entry types manually scraped from: http://kapeli.com/docsets
supported_entry_types = ["Attribute", "Binding", "Callback", "Category", "Class", "Command", "Constant", "Constructor",
                         "Define", "Directive", "Element", "Entry", "Enum", "Error", "Event", "Exception", "Field",
                         "File", "Filter", "Framework", "Function", "Global", "Guide", "Instance", "Instruction",
                         "Interface", "Keyword", "Library", "Literal", "Macro", "Method", "Mixin", "Module",
                         "Namespace", "Notation", "Object", "Operator", "Option", "Package", "Parameter", "Property",
                         "Protocol", "Record", "Sample", "Section", "Service", "Struct", "Style", "Tag", "Trait",
                         "Type", "Union", "Value", "Variable"]
# Attempt to parse latest online listing of entry types
supported_entry_types = Nokogiri::HTML(open('http://kapeli.com/docsets2')).css('.drowx > span').collect { |i| i.text }

################################################################
### File system entries

DOCSET_PATH = File.expand_path(File.join('~/', 'Library', 'Application Support', 'Dash', 'DocSets', 'CouchDB-1.4.docset'))
DOC_ROOT    = File.join DOCSET_PATH, 'Contents', 'Resources', 'Documents'
PLIST_PATH  = File.join DOCSET_PATH, 'Contents', 'info.plist'

# Create docset directory in the default location for Mac OSX
FileUtils.makedirs DOC_ROOT

# Create SQLite database
File.new(File.join(DOCSET_PATH, 'Contents', 'Resources', 'docSet.dsidx'), 'w')

# Copy Files
Dir.chdir File.dirname(__FILE__)
FileUtils.copy 'couchdb-icon-32px.png', File.join(DOCSET_PATH, 'icon.png')
FileUtils.cp_r 'couchdb-1.4/.', DOC_ROOT

### SQLite database initialization
$db = SQLite3::Database.new File.join(DOCSET_PATH, 'Contents', 'Resources', 'docSet.dsidx')

# Use this command to remove the index table
#$db.execute "DROP TABLE searchIndex"

# Generate the SQLite database records for the Dash docset index with these commands
$db.execute "CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);"
$db.execute "CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);"

### Plist generation/modification

default_plist = {
		'CFBundleIdentifier'   => 'CouchDB',
		'CFBundleName'         => 'CouchDB 1.4',
		'DocSetPlatformFamily' => 'CouchDB',
		'isDashDocset'         => true
}
additions = {
		'DocSetPubliserName' => 'Stephen C. Benner',
		'dashIndexFilePath'  => 'index.html' # interesting snag - setting an absolute path here will NOT work
		#'isJavaScriptEnabled' => true # enables .js scripts in Dash docsets
}

# Parse plist file
# plist = Plist::parse_xml PLIST_PATH
# Create new plist file
File.open(PLIST_PATH, 'w') { |f| f.write default_plist.update(additions).to_plist }

################################################################

# Micro helpers for DRY and semantic code!

# removes the numbers before each title: "1. Title" => "Title"
def remove_title(text)
  text.gsub(/[\d.+]* ?(.*)/, '\\1')
end

# Parse the following HTML files containing the documentation, using Nokogiri and CSS selectors to scrape the content
files = [
    'index.html',
    'api-basics.html',
    'query-servers.html',
    File.join('api', 'reference.html')
]

# This technique for creating a docset is based on mapping the HTML content to Dash's identifiers (entry types); in this
# case I identified the correct selectors for appropriate data using web dev tools in Chrome, and Nokogiri does the rest
entries = {}
files.collect { |filepath| File.open(File.join(DOC_ROOT, filepath), 'r') { |f| Nokogiri::XML f } }.each do |html|
	case fname = File.basename(html.url, '.html') # no need to keep typing the file extension
    when 'index'
      entries[:Guide] = {
          :entries => html.css('.toctree-l1 > a').reject { |e| e.text =~ /Reference/ }.collect { |e| remove_title e.text },
          :links => html.css('.toctree-l1 > a').collect { |e| e.attr('href') }
      }
      entries[:Category] = {
          :entries => html.css('.toctree-l1:nth-of-type(9) a').collect { |e| remove_title e.text },
          :links => html.css('.toctree-l1:nth-of-type(9) a').collect { |e| e.attr('href') }
      }
      entries[:Struct] = {
          :entries => html.css('.toctree-l1:nth-of-type(10) ul a').collect { |e| remove_title e.text },
          :links => html.css('.toctree-l1:nth-of-type(10) ul a').collect { |e| e.attr('href') }
      }
      entries[:Option] = {
          :entries => html.css('.toctree-l1:nth-of-type(11) ul a').collect { |e| remove_title e.text },
          :links => html.css('.toctree-l1:nth-of-type(11) ul a').collect { |e| e.attr('href') }
      }

    when 'reference'
      entries[:Method] = {
          :entries => html.css('.toctree-l2 > a').collect { |e| remove_title e.text },
          :links => html.css('.toctree-l2 > a').collect { |e| File.join 'api', e.attr('href') }
      }

    when 'api-basics'
      entries[:Type] = {
          :entries => html.css('#request-format-and-responses ul p span').collect { |e| remove_title e.text },
          :links => html.css('#request-format-and-responses h2 a').collect { |e| "api-basics.html#{e.attr 'href'}" }
      }
      entries[:Protocol] = {
          :entries => html.css('.body > .section h2, .body > .section h3').collect { |e| remove_title e.children.sort.first.text },
          # filter URLs to only select subsections
          :links => html.css('.headerlink').reject { |e| e.attr('href') == '#api-basics' }.collect { |e| "api-basics.html#{e.attr 'href'}" }
      }

    when 'query-servers'
      entries[:Function] = {
          :entries => html.css('.function .descname').collect { |e| remove_title e.text },
          :links => html.css('.function a.headerlink:last-of-type').collect { |e| "query-servers.html#{e.attr 'href' }" }
      }

		else
			raise "ERROR: Bad filename ('#{fname}')"
  end
end

# Iterate over the two arrays, saving text and url data as entries
entries.each do |entry_type, data|
  data[:entries].zip(data[:links]).each do |name, url|
    $db.execute "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('#{name}', '#{entry_type}', '#{url}');"
  end
end