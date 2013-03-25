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
      Thread.current[:request_queue] ||= Typhoeus::Hydra.new(:max_concurrency => LazyResource.max_concurrency)
    end

    def run
      send_to_request_queue!
      request_queue.run if request_queue.items_queued?
    end

    def send_to_request_queue!
      while(relation = @queue.pop)
        request = Request.new(url_for(relation), relation, :headers => relation.headers)
        request_queue.queue(request)
      end
    end

    def url_for(relation)
      if relation.route.nil?
        url = ''
        url << relation.klass.site
        url << self.class.collection_path(relation.to_params, nil, relation.from)
        url
      else
        url = relation.route
        url.gsub!(/:\w*/) do |match|
          attr = match[1..-1].to_sym
          if relation.where_values.has_key?(attr)
            relation.where_values[attr]
          else
            match
          end
        end

        if url =~ /http/
          url
        else
          relation.klass.site + url
        end
      end
    end
  end
end
