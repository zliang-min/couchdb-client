module CouchDB
  class Document < JSONObject
    class << self
      alias fixed_schema!   fixed_structure!
      alias fixed_schema?   fixed_structure?
      alias dynamic_schema! dynamic_structure!
      alias dynamic_schema? dynamic_structure?
    end

    attr_reader :db

    def initialize(db, attributes = nil)
      super attributes
      @db = db
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
      replace db.put(self)
    end

    def update!(attributes)
      update attributes
      save
    end

    def delete!
      raise InvalidOperation, "Can not delete a document without _id or _rev." unless id and rev
      db.delete id, rev
    end
  end
end
