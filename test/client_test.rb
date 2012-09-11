# encoding: utf-8

require 'test_helper'

class ClientTest < CouchDB::TestCase
  def test_get_all_dbs
    assert_includes client.all_dbs, 'couchdb-client_test_fixtures'
  end

  def test_get_all_documents
    resp = db.all_docs

    assert_equal resp['total_rows'], resp['rows'].size
  end

  def test_create_documents
    doc = db.put :type => 'human', :name => 'Gimi'

    assert_kind_of CouchDB::Document, doc
    assert doc.id
    assert doc.rev
  end

  def test_get_documents
    doc  = db.put :type => 'human', :name => 'Gimi'
    doc2 = db.get doc.id

    assert_kind_of CouchDB::Document, doc2
    assert_equal doc.id, doc2.id
    assert_equal doc.rev, doc2.rev
    assert_equal doc.values_at('type', 'name'), doc2.values_at('type', 'name')
  end

  def test_update_documents
    doc = db.put :type => 'human', :name => 'Gimi'
    rev = doc.rev
    doc.update! :name => 'GimiL'

    assert_equal 'GimiL', doc['name']
    refute_equal rev, doc.rev
  end

  def test_delete_documents
    doc = db.put :type => 'human', :name => 'Gimi'
    doc.delete!
    assert_raises CouchDB::HTTPError do
      db.get doc.id
    end
  end
end
