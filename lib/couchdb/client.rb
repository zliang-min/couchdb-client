module CouchDB
  class Client
    def self.default_options
      {:host => 'localhost', :port => 5984}
    end

    def initialize(options = {})
      options = self.class.default_options.merge normalize_options(options)
      @connection = establish_connection options
    end

    def all_dbs
      get '_all_dbs'
    end

    # Public: Get a Database with the given name.
    def db(name, doc_class = Document)
      DataBase.new self, name, doc_class
    end
    
    alias [] db

    def get(path, options = {})
      send_http_request :get, path, options
    end

    def put(path, options = {})
      send_http_request :put, path, {:headers => {'Content-Type' => 'application/json'}}.merge!(options)
    end

    def post(path, options = {})
      send_http_request :post, path, {:headers => {'Content-Type' => 'application/json'}}.merge!(options)
    end

    def delete(path, options = {})
      send_http_request :delete, path, options
    end

    def head(path, options = {})
      send_http_request :head, path, options
    end

    private

    attr_reader :connection

    def normalize_options(options)
      options.inject({}) { |h, (k, v)| h[k.to_sym] = v; h }
    end

    def establish_connection(options)
       class << self; self end.tap { |singleton_class|
        singleton_class.send :include, HTTParty
        singleton_class.base_uri base_uri_from_options(options)
       }
    end

    def base_uri_from_options(options)
      scheme = options[:ssl] ? 'https' : 'http'
      "#{scheme}://#{options[:host]}".tap { |uri|
        uri << ":#{options[:port]}" if options[:port]
      }
    end

    def send_http_request(verb, path, options = {})
      CouchDB.debug { "[CouchDB] Request: #{verb} /#{path} #{options.inspect}" }
      resp = connection.send(verb, "/#{path}", options)
      CouchDB.debug { "[CouchDB] Response: #{resp.code} #{resp.body.inspect}" }
      if resp.code < 300
        JSON.load resp.body
      else
        raise HTTPError, resp
      end
    end
  end

end
