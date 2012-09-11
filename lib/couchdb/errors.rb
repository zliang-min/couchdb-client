module CouchDB
  class Error < RuntimeError; end

  class InvalidOperation < Error; end

  class InvalidObject < Error; end

  class UnknownProperty < InvalidObject
    attr_accessor :name

    def initialize(name)
      @name = name
      super "Property #{name.inspect} is not declared."
    end
  end

  class MissingProperty < InvalidObject
    attr_accessor :name

    def initialize(name)
      @name = name
      super "Property #{name.inspect} is required, but not given."
    end
  end

  class InvalidValue < InvalidObject
    attr_accessor :property, :value

    def initialize(property, value)
      @property, @value = property, value
      super "#{value.inspect} is not a valid value for #{property}"
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