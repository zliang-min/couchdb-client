# encoding: utf-8

require 'test_helper'

class DatabaseTest < CouchDB::TestCase
  def test_default_doc_class
    doc = db.put :type => 'person', :name => 'Gimi'
    assert_instance_of CouchDB::Document, doc
  end

  def test_custom_doc_class
    db = client.db(db_name, TestDoc)

    assert_raises CouchDB::InvalidObject do
      db.put :key => 'value'
    end

    doc = db.put :name => 'Gimi'
    assert_instance_of TestDoc, doc
    assert_equal 'person', doc['type']
  end

  def test_exist
    refute db.exist?('non_exist_id')
  end

  class TestDoc < CouchDB::Document
    property :type, :string, :default  => 'person'
    property :name, :string, :required => true
  end
end
