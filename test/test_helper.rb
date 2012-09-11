require 'rubygems'

require 'bundler'
Bundler.setup

require 'couchdb-client'
require 'minitest/autorun'

class CouchDB::TestCase < MiniTest::Unit::TestCase
  attr_reader :client, :db

  def setup
    super

    @client = CouchDB.connect
    @db = @client[db_name]
    @db.ensure_exist!
  end

  def teardown
    db.delete!
  end

  private

  def db_name
    @db_name ||= 'couchdb-client_test_fixtures'
  end
end
