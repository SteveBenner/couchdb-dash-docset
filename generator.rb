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

# The main task of creating a docset is to map the HTML content to Dash's identifiers (entry types); obviously this is
# volatile and subject to change upon new releases of either CouchDB documentation or Dash.

# This helper does the 'ground-work' so we can bypass having to write even one line of ugly-ass SQL
# todo: decide whether or not to order entries based on their numerical value in the docs

def add_entries(type, selector, url_selector = nil, filter = nil, url_filter = nil, &block)
	abort 'Invalid database.' unless $db.class == SQLite3::Database

	# Group the Nokogiri HTML element collections representing 'name' and 'url' and enumerate through them concurrently
	# A 'Proc' object can be passed to filter each collection of nodes before processing
	url_selector ||= selector
	names        = (filter.nil? ? $html.css(selector).sort : $html.css(selector).sort.reject(&filter))
	urls         = (url_filter.nil? ? $html.css(url_selector).sort : $html.css(url_selector).sort.reject(&url_filter))
	urls         = urls.cycle # using an enumerator allows us to process a collection of 'urls' smaller than 'names'
	raise "No elements found using selector: '#{url_selector.to_s}'" if urls.none?

	names.each do |name_elem| # Nokogiri::XML::Element
		url_elem = urls.next
		url      = url_elem.attr 'href' # String

		# The entry name and url are determined by the return value of the given blocks, for simple arbitrary modification
		if block_given? # NOTE: returning multiple arguments in a single-line block has to be done via array
			case block.arity
				when 2
					name, url = yield(name_elem, url)
				when 1
					name = yield(name_elem)
				when 0
					name = name_elem.text
				else
					raise "ERROR: Wrong number of arguments to block (#{block.arity})"
			end
		end

		$db.execute "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('#{name}', '#{type}', '#{url}');"
	end
end

# Enumerate through files, using Nokogiri to parse the HTML, CSS selectors to find the data, and regexes to format it
[
		'index.html',
		'api-basics.html',
		'query-servers.html',
		File.join('api', 'reference.html')
]
.collect { |filepath| File.open(File.join(DOC_ROOT, filepath), 'r') { |f| Nokogiri::XML f } }.each do |html|
	$html = html # I find this quite inelegant, but I wasn't able to figure out how to access the local 'html' variable
	             # representing the current Nokogiri::XML::Document from inside the helper method, so I reverted to using
	             # a global as I don't have time to investigate further. I pretty much set myself up for this one by
	             # implementing this operation with such arcane method/block chaining and closure usage...

	case fname = File.basename(html.url, '.html') # no need to keep typing the file extension
		when 'index'
			# Typical regex removes numbers before each title: "1. Title" => "Title"

			add_entries(
					'Guide', '.toctree-l1 > a', nil,
					Proc.new { |e| e.text =~ /Reference/ } # references have their own entry types
			) { |e| e.text.gsub(/\d+\. ?(.*)/, '\\1') }

			add_entries('Category', '.toctree-l1:nth-of-type(9) a')   { |e| e.text.gsub(/[\d.+]* ?(.*)/, '\\1') }
			add_entries('Struct', '.toctree-l1:nth-of-type(10) ul a') { |e| e.text.gsub(/[\d.+]* ?(.*)/, '\\1') }
			add_entries('Option', '.toctree-l1:nth-of-type(11) ul a') { |e| e.text.gsub(/[\d.+]* ?(.*)/, '\\1') }

		when 'reference'
			add_entries('Method', '.toctree-l2 > a'
			) { |e, url| [ e.text.gsub(/[\d.+]* ?(.*)/, '\\1'), File.join('api', url) ] }

		when 'api-basics'
			add_entries(
					'Type', '#request-format-and-responses ul p span', '#request-format-and-responses h2 a'
			) { |e, url| [ e.text.gsub(/[\d.+]* ?(.*)/, '\\1'), "api-basics.html#{url}" ] }

			add_entries(
					'Protocol', '.body > .section h2, .body > .section h3', '.headerlink', nil,
					lambda { |e| e.attr('href') == '#api-basics' } # we don't want the section header, just subsections
			) { |e, url| [ e.children.sort.first.text.gsub(/[\d.+]* ?(.*)/, '\\1'), "api-basics.html#{url}" ] }

		when 'query-servers'
			add_entries('Function', '.function .descname', '.function a.headerlink:last-of-type'
			) { |e, url| [ e.text, "query-servers.html#{url}" ] }

		else
			raise "ERROR: Bad filename ('#{fname}')"
	end
end