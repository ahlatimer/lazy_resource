require 'active_support/core_ext/hash/slice'

module LazyResource
  class Relation
    class << self
      def resource_queue
        Thread.current[:resource_queue] ||= ResourceQueue.new
      end
    end

    attr_accessor :fetched, :klass, :values, :from, :site, :other_attributes

    def initialize(klass, options = {})
      @klass = klass
      @values = options.slice(:where_values, :order_value, :limit_value, :offset_value, :page_value)
      @fetched = options[:fetched] || false
      unless fetched?
        resource_queue.queue(self)
      end

      self
    end

    def from
      @from || self.klass.from || self.klass.collection_name
    end

    def collection_name
      from
    end

    def to_params
      params = {}
      params.merge!(where_values) unless where_values.nil?
      params.merge!(:order => order_value) unless order_value.nil?
      params.merge!(:limit => limit_value) unless limit_value.nil?
      params.merge!(:offset => offset_value) unless offset_value.nil?
      params.merge!(:page => page_value) unless page_value.nil?
      params
    end

    def load(objects)
      @fetched = true

      if mapped_name = @klass.mapped_root_node_name(objects)
        other_attributes = objects.dup
        objects = other_attributes.delete(mapped_name)
        @other_attributes = other_attributes
      end

      @result = objects.map do |object|
        @klass.load(object)
      end
    end

    def headers
      @headers ||= @klass.default_headers
    end

    def resource_queue
      self.class.resource_queue
    end

    def where(where_values)
      if @values[:where_values].nil?
        @values[:where_values] = where_values
      else
        @values[:where_values].merge!(where_values)
      end

      self
    end

    def order(order_value)
      @values[:order_value] = order_value
      self
    end

    def limit(limit_value)
      @values[:limit_value] = limit_value
      self
    end

    def offset(offset_value)
      @values[:offset_value] = offset_value
      self
    end

    def page(page_value)
      @values[:page_value] = page_value
      self
    end

    def where_values
      @values[:where_values]
    end

    def order_value
      @values[:order_value] 
    end

    def limit_value
      @values[:limit_value]
    end

    def offset_value
      @values[:offset_value]
    end

    def page_value
      @values[:page_value]
    end

    def fetched?
      @fetched
    end

    def to_a
      resource_queue.run if !fetched?
      result
    end

    def result
      @result ||= []
    end

    def respond_to?(method, include_private = false)
      super || result.respond_to?(method, include_private)
    end

    def as_json(options = {})
      to_a.map do |record|
        record.as_json
      end
    end

    def method_missing(name, *args, &block)
      if result.respond_to?(name)
        self.to_a.send(name, *args, &block)
      else
        super
      end
    end
  end
end
