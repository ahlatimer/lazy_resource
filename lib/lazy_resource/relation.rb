module LazyResource
  class Relation
    class << self
      def resource_queue
        Thread.current[:resource_queue] ||= ResourceQueue.new
      end
    end

    def initialize(klass, values = {})
      @klass = klass
      @values = values
      resource_queue.queue(self)
    end

    def load(objects)
      @result = @klass.load(objects)
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

    def to_a
      notify_resource_queue
      @result || []
    end

    def notify_resource_queue
      
    end

    def method_missing(name, *args, &block)
      if Array.instance_methods.include?(name)
        self.to_a.send(name, *args, &block)
      else
        super
      end
    end
  end
end
