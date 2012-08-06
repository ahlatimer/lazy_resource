module LazyResource
  module Attributes
    extend ActiveSupport::Concern
    include ActiveModel::Dirty

    module ClassMethods
      def attribute(name, type, options={})
        attributes[name] = { :type => type, :options => options }

        create_getter(name, type) unless options[:skip_getter]
        create_setter(name, type) unless options[:skip_setter]
        create_question(name, type) unless options[:skip_question] || options[:skip_getter]

        @attribute_methods_generated = false
        define_attribute_methods [name]
      end

      def fetch_all
        self.resource_queue.send_to_request_queue! if self.respond_to?(:resource_queue)
        self.request_queue.run if self.respond_to?(:request_queue)
      end

      def attributes
        @attributes ||= {}
      end

      def primary_key_name
        @primary_key_name ||= 'id'
      end

      def primary_key_name=(pk)
        @primary_key_name = pk
      end

      attr_writer :element_name
      def element_name
        @element_name ||= model_name.element
      end

      attr_writer :collection_name
      def collection_name
        @collection_name ||= ActiveSupport::Inflector.pluralize(element_name)
      end

      def create_setter(name, type)
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{name}=(value)
            self.class.fetch_all if !fetched?

            #{name}_will_change! unless @#{name} == value
            @#{name} = value
          end
        RUBY
      end

      def create_getter(name, type)
        method = <<-RUBY
          def #{name}
            self.class.fetch_all if !fetched
        RUBY

        if type.is_a?(Array) && type.first.include?(LazyResource::Resource)
          method << <<-RUBY
            if @#{name}.nil?
              @#{name} = #{type.first}.where(:"\#{self.class.element_name}_id" => self.primary_key)
            end
          RUBY
        elsif type.include?(LazyResource::Resource)
          method << <<-RUBY
            if @#{name}.nil?
              @#{name} = #{type}.where(:"\#{self.class.element_name}_id" => self.primary_key)
            end
          RUBY
        end

        method << <<-RUBY
            @#{name}
          end
        RUBY

        class_eval method, __FILE__, __LINE__ + 1
      end

      def create_question(name, type)
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{name}?
            !!self.#{name}
          end
        RUBY
      end
    end

    def primary_key
      self.send(self.class.primary_key_name)
    end

    included do
      extend ActiveModel::Naming
    end
  end
end
