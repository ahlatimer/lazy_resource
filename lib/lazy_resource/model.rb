module LazyResource
  class Model
    include ActiveModel::Naming
    include ActiveModel::Dirty

    include LazyResource::RequestDSL
    include LazyResource::RouterDSL
    include LazyResource::Persistence

    class << self
      attr_accessor :root_node_name, :primary_key_name

      def primary_key_name
        @primary_key_name ||= 'id'
      end

      def attributes
        @attributes ||= {}
      end

      def attribute(name, type, options={})
        attributes[name] = { type: type, options: options }

        define_method name do
          self.instance_variable_get("@#{name}")
        end

        define_method "#{name}=" do |value|
          self.send("#{name}_will_change!")
          self.instance_variable_set("@#{name}", value)
        end
      end

      def parse_attribute(name, value)
        if attributes[name] && attributes[name][:type].respond_to?(:parse)
          begin
            attributes[name][:type].parse(value)
          rescue
            value
          end
        else
          value
        end
      end

      def from_hash(hash)
        self.new.from_hash(hash)
      end

      def from_array(array)
        LazyResource::Collection.new(array).map do |hash|
          self.from_hash(hash)
        end
      end

      def from_json(json)
        if objects.is_a?(Array)
          self.from_array(json)
        else
          if mapped_name = self.mapped_root_node_name(json)
            self.from_json(json.delete(mapped_name)).tap do |obj|
              obj.other_attributes = json
            end
          else
            self.from_hash(json)
          end
        end
      end

      def mapped_root_node_name(objects)
        if self.root_node_name && objects.respond_to?(:keys)
          root_node_names = self.root_node_name.is_a?(Array) ? self.root_node_name : [self.root_node_name]
          (root_node_names.map(&:to_s) & objects.keys).first
        end
      end
    end

    def initialize(hash={})
      self.from_hash(hash, true)
    end

    def primary_key
      self.send(self.class.primary_key_name)
    end

    def from_hash(hash, will_change=false)
      hash.each do |attribute, value|
        self.send("#{attribute}_will_change!") if will_change
        self.instance_variable_set("@#{attribute}", self.class.parse_attribute(attribute, value))
      end
    end

    def as_json(options={})
      (options[:only_changed] ? self.changed_attributes : self.class.attributes).inject({}) do |hash, (attribute_name, _)|
        unless self.instance_variable_get("@#{attribute_name}").nil?
          value = self.send(:"#{attribute_name}")

          if value.is_a?(::Array) && value.first.include?(LazyResource::Resource)
            value = value.map { |v| v.as_json }
          elsif value.include?(LazyResource::Model)
            value = value.as_json
          end

          hash[attribute_name.to_sym] = value
        end
        hash
      end
    end

    def to_json(options={})
      self.as_json(options).to_json(options)
    end
  end
end
