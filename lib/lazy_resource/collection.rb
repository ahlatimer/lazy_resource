module LazyResource
  class Collection
    attr_accessor :klass, :results

    def initialize(klass, objects=[])
      @klass = klass
      self.load(objects)
    end

    def load(objects)
      @results = self.klass.load(objects)
    end

    def to_a
      @results || []
    end
  end
end
