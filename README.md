# Couchdb-client

'couchdb-client' is a pure ruby, easy to use CouchDB client library.

## Installation

Add this line to your application's Gemfile:

    gem 'couchdb-client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install couchdb-client

## Usage

    require 'couchdb-client'

    client = CouchDB.connect :host => 'localhost', :port => 5984 # => CouchDB::Client instance

    db = client['some_database'] # => CouchDB::Database

    doc = db.put 'key' => 'value'

    doc = db.get 'xxx' # => CouchDB::Document instance w/ _id 'xxx'

    doc.update!(:some_field => 'new_value')
    # or
    db.put doc.update('some_field' => 'new_value')

    doc.delete!
    # or
    db.delete doc._id

    db.exists? 'xxx'

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
