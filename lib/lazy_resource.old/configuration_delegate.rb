module LazyResource
  class ConfigurationDelegate
    def method_missing(method_name, *args, &block)
      [LazyResource::Resource, LazyResource].each do |klass|
        if klass.respond_to?(method_name)
          return klass.send(method_name, *args, &block)
        end
      end

      # if we didn't return from the each above, the method wasn't found
      super
    end
  end
end
