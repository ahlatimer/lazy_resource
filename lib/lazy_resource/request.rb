module LazyResource
  class Request
    class << self
      def queue
        Thread.current[:lazy_resource_queue] ||= []
      end
    end

    def initialize(model_or_class)
      self.tap do
        if model_or_class.is_a?(LazyResource::Model)
          @model = model_or_class
          @model_class = @model.class
        else
          @model_class = model_or_class
        end

        self.class.queue.push(self)
      end
    end

    def params(params={})
      self.tap do
        @params ||= {}
        @params.merge!(params)
      end
    end

    def route(*args)
      self.tap do

      end
    end

    def headers(headers={})
      self.tap do
        @headers ||= {}
        @headers.merge!(params)
      end
    end

    def body(body)
      self.tap do
        @body = body
      end
    end

    def method(method)
      self.tap do
        @method = method
      end
    end

    def success?
      true
    end

    def to_hash
      {
        params: @params,
        route: @route,
        headers: @headers,
        body: @body,
        method: @method
      }
    end

    def method_missing(method_name, *args, &block)
      if @model_class.respond_to?(method_name)
        request = @model_class.send(method_name)
        merge(request)
      else
        super(method_name, *args, &block)
      end
    end

    private
    def merge(other)
      other.to_hash.each do |k,v|
        self.send(k, v)
      end
    end
  end
end
