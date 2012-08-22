module LazyResource
  module Mapping
    extend ActiveSupport::Concern

    attr_accessor :fetched, :persisted, :other_attributes

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
        objects.fetched = true and return objects if objects.kind_of?(LazyResource::Mapping)

        if objects.is_a?(Array)
          Relation.new(self, :fetched => true).tap do |relation|
            relation.load(objects)
          end
        else
          if self.root_node_name && objects.key?(self.root_node_name.to_s)
            self.load(objects.delete(self.root_node_name.to_s)).tap do |obj|
              obj.other_attributes = objects
            end
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

        if resource.class.root_node_name && hash.key?(resource.class.root_node_name.to_s)
          other_attributes = hash
          hash = other_attributes.delete(resource.class.root_node_name.to_s)
          self.other_attributes = other_attributes
        end

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
