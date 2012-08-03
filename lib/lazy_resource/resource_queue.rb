module LazyResource
  class ResourceQueue
    include LazyResource::UrlGeneration

    def initialize
      @queue = []
    end

    def queue(relation)
      @queue.push(relation)
    end

    def flush!
      @queue = []
    end

    def request_queue
      Thread.current[:request_queue] ||= Typhoeus::Hydra.new
    end

    def run
      send_to_request_queue!
      request_queue.run
    end

    def send_to_request_queue!
      while(relation = @queue.pop)
        request = Request.new(url_for(relation), relation)
        request_queue.queue(request)
      end
    end

    def url_for(relation)
      url = ''
      url << relation.klass.site
      url << self.class.collection_path(relation.to_params, nil, relation.from)
      url
    end
  end
end
