module LazyResource
  class LogSubscriber < ActiveSupport::LogSubscriber
    def request(event)
      info "\s\s\s\s[#{event.payload[:code]}](#{((event.payload[:time] || 0) * 1000).ceil}ms) #{event.payload[:url]}"
    end

    def request_group_started(event)
      info "Processing requests:"
    end

    def request_group_finished(event)
      info "Requests finished in #{((event[:end_time] - event[:start_time]) * 1000).ceil}ms"
    end
  end
end

LazyResource::LogSubscriber.attach_to(:lazy_resource)
