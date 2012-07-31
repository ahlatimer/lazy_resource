module LazyResource
  module Resource
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

    def initialize(attributes={})
      self.tap do |resource|
        resource.load(attributes)
      end
    end

    def load(attributes)
      self.tap do |resource|
        attributes.each do |name, value|
          resource.send(:"#{name}=", value)
        end
      end
    end

    included do
      extend ActiveModel::Naming
      include ActiveModel::Conversion
      include Attributes
    end
  end
end
