module CouchDB
  class Error < RuntimeError; end

  class InvalidOperation < Error; end

  class PropertyError < Error
    attr_reader :name

    def initialize(name, msg = nil)
      @name = name
      msg ||= "Property error: #{name}"
      super msg
    end

    def to_hash
      {:property => name, :error => 'error'}
    end
  end

  class UndefinedProperty < PropertyError
    def initialize(name)
      super name, "Property #{name.inspect} is not defined."
    end

    def to_hash
      {:property => name, :error => 'undefined'}
    end
  end

  class MissingProperty < PropertyError
    def initialize(name)
      super name, "Property #{name.inspect} is required, but not given."
    end

    def to_hash
      {:property => name, :error => 'missing'}
    end
  end

  class InvalidValue < PropertyError
    attr_accessor :value, :reason

    def initialize(name, value, reason = nil)
      @value, @reason = value, reason
      super name, "#{value.inspect} is not a valid value for #{name} (#{reason})."
    end

    def to_hash
      {:property => name, :value => value, :error => 'invalid'}
    end
  end

  class InvalidObject < Error
    attr_reader :errors

    def initialize(json_object)
      @errors = json_object.errors.inject({}) { |h, (name, error)|
        h[name] = case error
                  when PropertyError
                    error.to_hash.tap { |hash| hash.delete :property }
                  when InvalidObject
                    error.to_hash
                  else
                    {:error => 'unknown'}
                  end
        h
      }

      super "#{json_object.inspect} is invalid."
    end

    def to_hash
      @errors
    end

    def to_json
      JSON.fast_generate @errors
    end
  end

  class HTTPError < Error
    attr_reader :code, :body

    def initialize(response)
      @code = response.code
      @body = JSON.parse response.body if response.body

      super @body ? @body['reason'] : @code
    end
  end
end
