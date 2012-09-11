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
      @db ||= connection[db_name, doc_class]
    end

    def self.set_db_name(name)
      @db_name = name
    end

    def self.db_name
      @db_name || superclass <= Model && superclass.db_name || nil
    end

    def self.set_doc_class(doc_class)
      raise ArgumentError, "Not a Document." unless doc_class <= Document
      @doc_class = doc_class
      db.set_doc_class doc_class
    end

    def self.doc_class
      @doc_class || superclass <= Model && superclass.doc_class || Document
    end

    def self.find(id)
      new db.find(id)
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
  end
end
