module LazyResource
  module Mapping
    extend ActiveSupport::Concern

    module ClassMethods
      def load(objects)
        if objects.is_a?(Array)
          objects.map do |object|
            self.new.load(object)
          end
        else
          self.new.load(objects)
        end
      end
    end

    def load(hash)
      return hash if hash.kind_of?(LazyResource::Mapping)

      self.tap do |resource|
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
      end
    end
  end
end
