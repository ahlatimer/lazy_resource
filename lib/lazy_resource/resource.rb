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

    included do
      extend ActiveModel::Naming
      include ActiveModel::Conversion
      include Attributes, Mapping, Types
    end
  end
end
