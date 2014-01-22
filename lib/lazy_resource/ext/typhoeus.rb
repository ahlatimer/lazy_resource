module Typhoeus
  class Hydra
    def items_queued?
      @multi.items_queued? || self.queued_requests.size > 0
    end

    def run_with_logging
      if log?
        log { run_without_logging }
      else
        run_without_logging
      end
    end

    private
    def log?
      LazyResource.debug && LazyResource.logger && items_queued? && !running?
    end

    def running?
      @running || @multi.running?
    end

    def log(&block)
      start_time = Time.now
      ActiveSupport::Notifications.instrument('request_group_started.lazy_resource', start_time: start_time)

      yield

      ActiveSupport::Notifications.instrument('request_group_finished.lazy_resource', start_time: start_time, end_time: Time.now)
    end

    alias_method :run_without_logging, :run
    alias_method :run, :run_with_logging
  end
end

module Ethon
  class Multi
    def running?
      running_count > 0
    end

    def running_count
      @running_count ||= 0
    end

    def items_queued?
      easy_handles.size > 0
    end
  end

  def self.logger
    @logger ||= DevNull.new
  end

  class DevNull
    def method_missing(*args, &block)
    end
  end
end
