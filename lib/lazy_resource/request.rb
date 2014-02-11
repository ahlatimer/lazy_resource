module LazyResource
  class Request < Typhoeus::Request
    SUCCESS_STATUSES = [200, 201]

    attr_accessor :resource, :response

    def initialize(url, resource, options={})
      options = options.dup
      options[:headers] = (options[:headers] || {}).dup
      options[:headers][:Accept] ||= 'application/json'
      options[:headers].merge!(Thread.current[:default_headers]) unless Thread.current[:default_headers].nil?

      params = (URI.parse(url).query || '')
                  .split('&')
                  .map { |param| param.split('=') }
                  .inject({}) { |memo, (k,v)| memo[k] = v; memo }

      url.gsub!(/\?.*/, '')

      options[:params] ||= {}
      options[:params].merge!(params)
      options[:params].merge!(Thread.current[:default_params]) unless Thread.current[:default_params].nil?

      options[:method] ||= :get

      super(url, options)

      @resource = resource

      self.on_complete do
        log_response(response) if LazyResource.debug && LazyResource.logger
        @response = response
        handle_errors unless SUCCESS_STATUSES.include?(@response.code)
        parse
      end

      self
    end

    def log_response(response)
      ActiveSupport::Notifications.instrument('request.lazy_resource', code: response.code, time: response.time, url: url)
    end

    def parse
      unless self.response.body.nil? || self.response.body == ''
        @resource.load(JSON.parse(self.response.body))
      end
    end

    def handle_errors
      case @response.code
      when 300...400
        raise Redirection.new(@response)
      when 400
        raise BadRequest.new(@response)
      when 401
        raise UnauthorizedAccess.new(@response)
      when 403
        raise ForbiddenAccess.new(@response)
      when 404
        raise ResourceNotFound.new(@response)
      when 405
        raise MethodNotAllowed.new(@response)
      when 409
        raise ResourceConflict.new(@response)
      when 410
        raise ResourceGone.new(@response)
      when 422
        raise UnprocessableEntity.new(@response)
      when 400...500
        raise ClientError.new(@response)
      when 500...600
        raise ServerError.new(@response)
      end
    end
  end
end
