module LazyResource
  class Request < Typhoeus::Request
    SUCCESS_STATUSES = 200...300

    attr_accessor :resource, :response

    def initialize(url, resource, options={})
      options = options.dup
      options[:headers] = (options[:headers] || {}).dup
      options[:headers][:Accept] ||= 'application/json'
      options[:headers].merge!(Thread.current[:default_headers]) unless Thread.current[:default_headers].nil?

      params = (URI.parse(url).query || '')
                  .split('&')
                  .map { |param| param.split('=') }
                  .inject({}) { |memo, (k,v)| memo[URI.unescape(k)] = v.nil? ? v : URI.unescape(v); memo }

      url.gsub!(/\?.*/, '')

      options[:params] ||= {}
      options[:params].merge!(params)
      options[:params].merge!(Thread.current[:default_params]) unless Thread.current[:default_params].nil?

      options[:method] ||= :get

      if [:post, :put].include?(options[:method])
        options[:headers]['Content-Type'] = 'application/json'
      end

      super(url, options)

      @resource = resource

      self.on_complete do
        log_response(response) if LazyResource.debug && LazyResource.logger
        @response = response
        parse
      end

      self
    end

    def log_response(response)
      ActiveSupport::Notifications.instrument('request.lazy_resource', code: response.code, time: response.time, url: url)
    end

    def parse
      if !SUCCESS_STATUSES.include?(@response.code)
        @resource.request_error = error
      elsif !self.response.body.nil? && self.response.body != ''
        @resource.load(JSON.parse(self.response.body))
      end
    end

    def error
      case @response.code
      when 300...400
        Redirection.new(@response)
      when 400
        BadRequest.new(@response)
      when 401
        UnauthorizedAccess.new(@response)
      when 403
        ForbiddenAccess.new(@response)
      when 404
        ResourceNotFound.new(@response)
      when 405
        MethodNotAllowed.new(@response)
      when 409
        ResourceConflict.new(@response)
      when 410
        ResourceGone.new(@response)
      when 422
        UnprocessableEntity.new(@response)
      when 400...500
        ClientError.new(@response)
      when 500...600
        ServerError.new(@response)
      end
    end
  end
end
