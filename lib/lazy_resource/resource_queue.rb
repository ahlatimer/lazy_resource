module LazyResource
  class ResourceQueue
    def initialize
      @queue = []
    end

    def queue(relation)
      @queue.push(relation)
    end

    def run
      while(relation = @queue.pop)
        # do something
      end
    end
  end
end
