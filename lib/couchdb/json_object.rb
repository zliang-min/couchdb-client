module CouchDB
  # Public: The Ruby class that represents the JSON Object.
  #         All properties (keys) in a JSONObject are strings.
  #         (even strings are not the best hash key in Ruby)
  class JSONObject < Hash
    # Private: The propety definition object.
    class Property
      BuiltinTypes = {
        :string => lambda { |v| v.to_s },
        :int    => lambda { |v| Integer(v) },
        :float  => lambda { |v| Float(v) },
        :bool   => lambda { |v| !!v },
        :array  => lambda { |v| Array(v) },
        :hash   => lambda { |v| v.to_hash },
        :object => JSONObject
      }

      attr_reader :name, :default

      def initialize(name, type, options = {}, &blk)
        @name = name

        if type.is_a?(Symbol)
          raise ArgumentError, "Unknow property type #{type.inspect}." unless BuiltinTypes.has_key?(type)
          type = BuiltinTypes[type] 
        end
        type = Class.new JSONObject, &blk if type == JSONObject

        @convertor =
          if type.respond_to?(:call)
            type
          elsif convert_method = [:convert, :new].detect { |m| type.respond_to? m }
            type.method convert_method
          else
            raise ArgumentError, "Property type should has :convert, :call or :new method."
          end

        @required  = options[:required]
        @default   = options[:default]
        @validator = options[:validate]
      end

      def required?
        @required
      end

      def has_default?
        !@default.nil?
      end

      def convert(value)
        @convertor.call value
      rescue
        raise $!.is_a?(InvalidValue) ? $! : InvalidValue.new(name, value)
      end

      def valid_value?(value)
        @validator.nil? or value.nil? or @validator.call(value)
      end
    end # Property

    # Public: Make this object become a fixed struture object, which means
    #         all properties of this object have to be declared (using the
    #         `property` method) before being used.
    def self.fixed_structure!
      @fixed_structure = true
    end

    # Public: Make this object a dynamic struture object, which means
    #         its properties are dynamic (just like a Hash).
    def self.dynamic_structure!
      @fixed_structure = false
    end

    def self.fixed_structure?
      @fixed_structure
    end

    def self.dynamic_structure?
      not fixed_structure?
    end

    # Public: Properties will inherit from the parent class.
    def self.properties
      @properties ||= {}.tap { |h| h.merge! superclass.properties if superclass < JSONObject }
    end

    def self.property(name, type = :string, options = {}, &blk)
      name = name.to_s
      properties[name] = Property.new(name, type, options, &blk)
    end

    # Public: lookup a property definition by its name.
    def self.lookup(property_name)
      properties[property_name.to_s]
    end

    attr_reader :errors

    def initialize(data = nil)
      replace data if data
      set_defaults
      @errors = {}
    end

    def []=(name, value)
      super name.to_s, convert_value(name, value)
    end

    def store(name, value)
      super name.to_s, convert_value(name, value)
    end

    def update(data)
      super convert_hash(data)
    end

    def merge!(data)
      super convert_hash(data)
    end

    def merge(data)
      super convert_hash(data)
    end

    def replace(data)
      super convert_hash(data)
    end

    def valid?
      validate!
      errors.empty?
    end

    def validate!
      errors.clear

      properties.each { |k, property|
        if property.required? and self[k].nil?
          errors[k] = MissingProperty.new(k)
          next
        end

        if not property.valid_value?(self[k])
          errors[k] = InvalidValue.new(k, self[k])
        end
      }
    end

    def inspect
      "#{self.class.name}#{super}"
    end

    private

    def properties
      self.class.properties
    end

    def fixed_structure?
      self.class.fixed_structure?
    end

    def dynamic_structure?
      self.class.dynamic_structure?
    end

    def convert_value(property_name, value)
      unless value.nil?
        property = self.class.lookup property_name
        raise UnknownProperty.new(property_name) if fixed_structure? && property.nil?
        value = property.convert(value) if property
      end

      value
    end

    def convert_hash(hash)
      Hash[hash.map { |k, v| [k.to_s, convert_value(k, v)] }]
    end

    def set_defaults
      properties.values.each { |property|
        self[property.name] = property.default if self[property.name].nil? and property.has_default?
      }
    end
  end
end
