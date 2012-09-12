module CouchDB
  class Document < JSONObject
    class << self
      alias fixed_schema!   fixed_structure!
      alias fixed_schema?   fixed_structure?
      alias dynamic_schema! dynamic_structure!
      alias dynamic_schema? dynamic_structure?
    end

    property :_id,  :string
    property :_rev, :string

    attr_reader :db

    def initialize(db, attributes = nil)
      super attributes
      @db = db
      send :after_initialize if respond_to?(:after_initialize)
    end

    def _rev
      self['_rev']
    end

    alias rev _rev

    def _id
      self['_id']
    end

    alias id _id

    def new_record?
      _id.nil?
    end

    def save
      send :before_save if respond_to?(:before_save)
      replace db.put(self)
    end

    def update!(attributes)
      send :before_update if respond_to?(:before_update)
      update attributes
      save
    end

    def delete!
      raise InvalidOperation, "Can not delete a document without _id or _rev." unless id and rev
      send :before_delete if respond_to?(:before_delete)
      db.delete id, rev
    end
  end
end
