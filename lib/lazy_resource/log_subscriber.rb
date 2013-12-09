module LazyResource
  class LogSubscriber < ActiveSupport::LogSubscriber
    def request(event)
      info "\s\s\s\s[#{event.payload[:code]}](#{((event.payload[:time] || 0) * 1000).ceil}ms) #{event.payload[:url]}"
    end
  end
end

LazyResource::LogSubscriber.attach_to(:lazy_resource)
