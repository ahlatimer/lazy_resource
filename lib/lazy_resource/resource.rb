module LazyResource
  module Resource
    extend ActiveSupport::Concern

    module ClassMethods
      def where(where_values)
        Relation.new(self, :where_values => where_values)
      end

      def order(order_value)
        Relation.new(self, :order_value => order_value)
      end

      def limit(limit_value)
        Relation.new(self, :limit_value => limit_value)
      end

      def offset(offset_value)
        Relation.new(self, :offset_value => offset_value)
      end
      
      def page(page_value)
        Relation.new(self, :page_value => page_value)
      end
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
