module LazyResource
  module Mapping
    extend ActiveSupport::Concern

    attr_accessor :fetched, :persisted

    def fetched?
      @fetched
    end

    def self.root_node_name=(node)
      @root_node_name = node
    end

    def self.root_node_name
      @root_node_name
    end

    module ClassMethods
      def root_node_name=(node)
        @root_node_name = node
      end

      def root_node_name
        @root_node_name || LazyResource::Mapping.root_node_name
      end

      def load(objects)
        if objects.is_a?(Array)
          objects.map do |object|
            self.new.load(object)
          end
        else
          if self.root_node_name && objects.key?(self.root_node_name.to_s)
            self.load(objects[self.root_node_name.to_s])
          else
            self.new.load(objects)
          end
        end
      end
    end

    def load(hash, persisted=true)
      hash.fetched = true and return hash if hash.kind_of?(LazyResource::Mapping)

      self.tap do |resource|
        resource.persisted = persisted
        resource.fetched = false
        
        hash = hash[resource.class.root_node_name.to_s] if resource.class.root_node_name && hash.key?(resource.class.root_node_name.to_s)
        hash.each do |name, value|
          attribute = self.class.attributes[name.to_sym]
          next if attribute.nil?

          type = attribute[:type]
          if type.is_a?(::Array)
            if type.first.include?(LazyResource::Mapping)
              resource.send(:"#{name}=", type.first.load(value))
            else
              resource.send(:"#{name}=", value.map { |object| type.first.parse(object) })
            end
          elsif type.include?(LazyResource::Mapping)
            resource.send(:"#{name}=", type.load(value))
          else
            resource.send(:"#{name}=", type.parse(value)) rescue StandardError
          end
        end

        resource.fetched = true
      end
    end
  end
end
