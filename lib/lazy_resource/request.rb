module LazyResource
  class Request
    class << self
      def queue
        Thread.current[:lazy_resource_queue] ||= []
      end

      def hydra
        Thread.current[:hydra] ||= Typhoeus::Hydra.new(:max_concurrency => LazyResource.max_concurrency)
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
        @params ||= Thread.current[:default_params] || {}
        @params.merge!(params)
      end
    end

    def route(*args, &block)
      self.tap do
        router.apply_overrides(*args, &block)
      end
    end

    def headers(headers={})
      self.tap do
        @headers ||= Thread.current[:default_headers] || {}
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
      run if @response.nil?
      @response.code >= 200 && @response.code < 300
    end

    def run(queue_others=true)
      if queue_others
        while(self.class.queue.any?)
          self.class.queue.pop.run(false)
        end
      end

      self.tap do
        url = router.url
        request = Typhoeus::Request.new(url, options)

        request.on_complete do |response|
          @response = response
          parse
        end

        hydra.queue(request)

        hydra.run if queue_others
      end
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
        request = @model_class.send(method_name, *args, &block)
        merge(request)
      elsif success? && @model.respond_to?(method_name)
        @model.send(methon_name, *args, &block)
      else
        super(method_name, *args, &block)
      end
    end

    private
    def router
      @router ||= Router.new(self, @model, @model_class)
    end

    def merge(other)
      other.to_hash.each do |k,v|
        self.send(k, v)
      end
    end

    def options
      self.to_hash.slice(:params, :headers, :body, :method).tap do |options|
        options[:headers][:Accept] ||= 'application/json'
        options[:headers]['Content-Type'] ||= 'application/json'
      end
    end

    def parse
      unless @response.body.nil? || @response.body == ''
        hash = JSON.parse(@response.body)

        if @model
          @model.from_hash(hash, false)
        else
          @model_class.from_json(hash)
        end
      end
    end
  end
end
