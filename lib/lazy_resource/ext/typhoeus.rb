module Typhoeus
  class Hydra
    def run_with_logging
      log = LazyResource.debug && LazyResource.logger && @multi.active > 0
      if log
        LazyResource.logger.info "Processing requests:"
        start_time = Time.now
      end

      run_without_logging

      if log
        LazyResource.logger.info "Requests processed in #{((Time.now - start_time) * 1000).ceil}ms"
      end
    end

    alias_method :run_without_logging, :run
    alias_method :run, :run_with_logging
  end

  class Multi
    attr_reader :active, :running
  end
end
