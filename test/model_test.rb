require 'test_helper'

class ModelTest < CouchDB::TestCase
  def setup
    super
    CouchDB::Model.establish_connection client
  end

  def test_read_method
    model = Class.new(CouchDB::Model) do
      set_doc_class Class.new(CouchDB::Document) {
        property :key_one, :object do
          property :inner_key, :string
        end

        property :key_two, :object do
          def foo
            'foo'
          end
        end
      }
    end

    model.set_db_name db_name

    sth = model.new :key_one => {:inner_key => 'inner_value'}, :key_two => {}

    assert_equal 'inner_value', sth.read('key_one.inner_key')
    assert_equal 'foo', sth.read('key_two.foo')
  end
end
