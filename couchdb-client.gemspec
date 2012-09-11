# -*- encoding: utf-8 -*-
require File.expand_path('../lib/couchdb/client/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Gimi Liang"]
  gem.email         = ["liang.gimi@gmail.com"]
  gem.description   = %q{A pure Ruby CouchDB client.}
  gem.summary       = %q{A pure Ruby CouchDB client.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "couchdb-client"
  gem.require_paths = ["lib"]
  gem.version       = CouchDB::Client::VERSION

  gem.add_dependency 'json',       ['~> 1.7.5']
  gem.add_dependency 'httparty',   ['~> 0.8.3']
end
