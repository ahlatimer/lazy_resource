module LazyResource
  class Router
    def initialize(request, model, model_class)
      @request = request
      @model = model
      @model_class = model_class
    end

    def apply_overrides(*args, &block)
      @uri = if args.length == 1
        args = args.first
        if args.is_a?(Hash)
          hash_overrides(args)
        elsif args.is_a?(LazyResource::Model)
          model_overrides(args)
        elsif args.is_a?(String)
          string_overrides(args)
        else
          args
        end
      else
        array_overrides(args)
      end
    end

    def url
      "#{@uri}?#{@request.params.map { |k, v| "#{k}=#{v}" }.join('&')}"
    end

    private
    def array_overrides(array)
      array.map { |item| apply_overrides(item) }.join('')
    end

    def model_overrides(model)
      "/#{model.collection_name}/#{model.primary_key}"
    end

    def hash_overrides(hash)
      hash.each { |k, v| "/#{k}/#{v}" }.join('')
    end

    def string_overrides(string)
      string.gsub(/:\w+/) do |match|
        @request.params.keys.include?(match.to_sym) ? @request.params.delete(match.to_sym) : match
      end
    end
  end
end
