module LazyResource
  module Resource
    extend ActiveSupport::Concern

    module ClassMethods
    end

    def initialize(attributes={})
      self.tap do |resource|
        resource.load(attributes)
      end
    end
    
    # Tests for equality. Returns true iff +other+ is the same object or
    # other is an instance of the same class and has the same attributes.
    def ==(other)
      return true if other.equal?(self)
      return false unless other.instance_of?(self.class)

      self.class.attributes.inject(true) do |memo, attribute|
        attribute_name = attribute.first
        memo && self.send(:"#{attribute_name}") == other.send(:"#{attribute_name}")
      end
    end
    
    def eql?(other)
      self == other
    end

    included do
      extend ActiveModel::Naming
      include ActiveModel::Conversion
      include Attributes, Mapping, Types
    end
  end
end
