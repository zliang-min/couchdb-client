module CouchDB
  class Model
    # call-seq
    #   establish_connection options
    #
    # call-seq
    #   establish_connection client
    def self.establish_connection(options_or_client)
      @connection = options_or_client
      @connection = Client.new connection unless connection.is_a?(Client)
    end

    def self.connection
      @connection || superclass <= Model && superclass.connection || nil
    end

    def self.db
      @db ||= connection && connection[db_name, doc_class]
    end

    def self.set_db_name(name)
      @db_name = name
    end

    def self.db_name
      @db_name || superclass <= Model && superclass.db_name || nil
    end

    def self.set_doc_class(doc_class)
      raise ArgumentError, "Not a Document." unless doc_class <= Document
      return if @doc_class == doc_class
      @doc_class = doc_class
      @db = nil
    end

    def self.doc_class
      @doc_class || superclass <= Model && superclass.doc_class || Document
    end

    def self.find(id)
      doc = db.find(id)
      new doc if doc
    end

    attr_reader :doc

    def initialize(attributes = nil)
      @doc = self.class.db.new_doc attributes
    end

    def [](attribute)
      @doc[attribute]
    end

    def []=(attribute, value)
      @doc[attribute] = value
    end

    def read(chained_keys, splitter = '.')
      chained_keys.split(splitter).inject(@doc) { |value, key|
        value = value.respond_to?(key) ? value.send(key) : value[key]
        break if value.nil?
        value
      }
    end

    def _id
      @doc._id
    end

    alias id _id

    def _rev
      @doc._rev
    end

    alias rev _rev

    def new_record?
      @doc.new_record?
    end

    def update(attributes)
      @doc.update! attributes
    end

    def save
      @doc.save
    end

    def delete
      @doc.delete!
      freeze
    end

    def to_hash
      @doc.to_hash
    end

    def to_json
      JSON.fast_generate @doc
    end

    private

    def freeze
      super
      @doc.frezze
    end
  end
end
