require 'json'
require 'httparty'

module CouchDB
  require 'couchdb/errors'

  require 'couchdb/client'
  require 'couchdb/database'
  require 'couchdb/json_object'
  require 'couchdb/document'

  require 'couchdb/model'

  class << self
    # Public: A sugar method for creating a Client instance.
    def connect(options = {})
      Client.new options
    end

    def logger
      @logger ||= begin
                    require 'logger'
                    Logger.new($stdout).tap { |logger| logger.level = $DEBUG ? Logger::DEBUG : Logger::INFO }
                  end
    end

    def logger=(logger)
      @logger = logger
    end

    def debug
      logger.debug yield if logger.debug?
    end
  end
end
