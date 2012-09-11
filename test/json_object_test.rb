require 'test_helper'

class JSONObjectTest < MiniTest::Unit::TestCase
  def test_keys_are_strings
    o = CouchDB::JSONObject.new
    o[:key] = 'some_value'
    assert_equal 'some_value', o['key']

    o = CouchDB::JSONObject.new :key => 'some_value'
    assert_equal 'some_value', o['key']
  end

  def test_builtin_type_converter
    skip
  end

  def test_dynamic_structure
    o = CouchDB::JSONObject.new
    o[:key] = 'some_value'
    assert o.valid?
  end

  def test_fixed_structure
    o = Class.new(CouchDB::JSONObject) do
      fixed_structure!

      property :valid_key
    end.new

    assert o['valid_key'] = 'some_value'
    assert_raises CouchDB::UnknownProperty do
      o['invalid_key'] = 'some_value'
    end
  end

  def test_required_property
    o = Class.new(CouchDB::JSONObject) do
      property :required_key, :string, :required => true
    end.new

    refute o.valid?
    assert_instance_of CouchDB::MissingProperty, o.errors['required_key']

    o[:required_key] = 'some_value'
    assert o.valid?
  end

  def test_property_validation
    o = Class.new(CouchDB::JSONObject) do
      property :key, :string, :validate => lambda { |v| %w[hello world].include? v }
    end.new

    o[:key] = 'hello'
    assert o.valid?

    o[:key] = 'hell'
    refute o.valid?
    assert_instance_of CouchDB::InvalidValue, o.errors['key']
  end

  def test_property_inherent
    parent = Class.new CouchDB::JSONObject do
      fixed_structure!

      property :name, :string, :required => true
    end

    child = Class.new parent do
      property :parent, :string, :required => true
    end

    p = parent.new :name => 'Gimi'
    assert p.valid?

    c = child.new :parent => 'Gimi'
    refute c.valid?
    assert_instance_of CouchDB::MissingProperty, c.errors['name']
  end
end
