module LazyResource
  module Attributes
    extend ActiveSupport::Concern

    module ClassMethods
      def attribute(name, type, options={})
        attributes[name] = { :type => type, :options => options }
        
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{name}
            self.class.fetch_all if !fetched?

            @#{name}
          end
          
          def #{name}?
            !!self.#{name}
          end

          def #{name}=(value)
            self.class.fetch_all if !fetched?

            #{name}_will_change! unless @#{name} == value
            @#{name} = value
          end
        RUBY

        @attribute_methods_generated = false
        define_attribute_methods [name]
      end

      def fetch_all
        self.class.resource_queue.send_to_request_queue!
        self.class.request_queue.run
      end

      def attributes
        @attributes ||= {}
      end
    end

    included do
      include ActiveModel::Dirty
    end
  end
end
