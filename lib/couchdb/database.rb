module CouchDB
  class DataBase
    attr_reader :name

    def initialize(client, name, doc_class = Document)
      raise ArgumentError, "doc_class must be a Document." unless doc_class <= Document

      @client = client
      @name = name
      @doc_class = doc_class
    end

    def set_doc_class(doc_class)
      raise ArgumentError, "doc_class must be a Document." unless doc_class <= Document

      @doc_class = doc_class
    end

    # Create or update a document.
    def create!
      client.put name
    end

    def ensure_exist!
      create!
    rescue HTTPError => e
      raise e unless e.code == 419
    end

    def delete!
      client.delete name
    end

    def all_docs(options = nil)
      client.get path_for('_all_docs')
    end

    def new_doc(data)
      doc_class.new self, data
    end

    # Public: retrieve a document by its _id. Also see `find`.
    def get(_id)
      new_doc client.get(path_for(_id))
    end

    # Public: retrieve a document by its _id.
    #
    # This method is similar to the `get` method, the only difference is
    # `get` will raise CouchDB::HTTPError when CouchDB returns errors,
    # while `find` will only return nil. Which means `get` gives you
    # a more flexible way to handle errors.
    def find(_id)
      get _id
    rescue HTTPError => e
      nil
    end

    # Public: put a hash-ish into the database.
    #
    # This method can be used to create and update a document.
    def put(data)
      data = new_doc data unless data.is_a?(doc_class)
      raise InvalidObject.new(data) unless data.valid?

      resp =
        if id = data.delete('_id')
          client.put path_for(id), :body => encode(data)
        else
          client.post name, :body => encode(data)
        end

      data.merge! '_id' => resp['id'], '_rev' => resp['rev']
    end

    def delete(_id, _rev)
      client.delete path_for(_id), :query => {'rev' => _rev}
    end

    # Public: is there a document whose id is _id?
    def exist?(_id)
      client.head path_for(_id)
    rescue CouchDB::HTTPError
      raise $! unless $!.code == 404
    end

    private

    attr_reader :client, :doc_class

    def path_for(_id)
      "#{name}/#{_id}"
    end

    def encode(document)
      JSON.fast_generate document
    end
  end
end
