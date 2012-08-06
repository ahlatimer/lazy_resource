module LazyResource
  module Resource
    extend ActiveSupport::Concern
    include ActiveModel::Conversion
    include Attributes, Mapping, Types, UrlGeneration

    included do
      extend ActiveModel::Callbacks
      define_model_callbacks :create, :update, :save, :destroy
    end

    def self.site=(site)
      @site = site
    end

    def self.site
      @site
    end

    module ClassMethods
      # Gets the URI of the REST resources to map for this class.  The site variable is required for
      # Active Async's mapping to work.
      def site
        if defined?(@site)
          @site
        else
          LazyResource::Resource.site
        end
      end

      # Sets the URI of the REST resources to map for this class to the value in the +site+ argument.
      # The site variable is required for Active Async's mapping to work.
      def site=(site)
        @site = site
      end

      def request_queue
        Thread.current[:request_queue] ||= Typhoeus::Hydra.new
      end

      def find(id, params={}, options={})
        resource = self.new
        resource.fetched = false
        resource.persisted = true
        request = Request.new(self.element_path(id, params), resource, options)
        request_queue.queue(request)
        resource
      end

      def where(where_values)
        Relation.new(self, :where_values => where_values)
      end

      def order(order_value)
        Relation.new(self, :order_value => order_value)
      end

      def limit(limit_value)
        Relation.new(self, :limit_value => limit_value)
      end

      def offset(offset_value)
        Relation.new(self, :offset_value => offset_value)
      end
      
      def page(page_value)
        Relation.new(self, :page_value => page_value)
      end

      def create(attributes={})
        new(attributes).tap do |resource|
          resource.run_callbacks :create do
            request = Request.new(resource.collection_url, resource, :method => :post, :params => { :user => attributes })
            request_queue.queue(request)
            fetch_all
          end
        end
      end
    end

    def initialize(attributes={})
      self.tap do |resource|
        resource.load(attributes)
        resource.persisted = false
      end
    end

    # Tests for equality. Returns true iff +other+ is the same object or
    # other is an instance of the same class and has the same attributes.
    def ==(other)
      return true if other.equal?(self)
      return false unless other.instance_of?(self.class)

      self.class.attributes.inject(true) do |memo, attribute|
        attribute_name = attribute.first
        attribute_type = attribute.last[:type]

        # Skip associations
        if attribute_type.include?(LazyResource::Resource) || (attribute_type.is_a?(::Array) && attribute_type.first.include?(LazyResource::Resource))
          memo
        else
          memo && self.send(:"#{attribute_name}") == other.send(:"#{attribute_name}")
        end
      end
    end
    
    def eql?(other)
      self == other
    end

    def persisted?
      @persisted
    end

    def new_record?
      !persisted?
    end

    alias :new? :new_record?

    def save
      return true if !changed?
      run_callbacks :save do
        new_record? ? create : update
        self.persisted = true
      end
    end

    def create
      run_callbacks :create do
        request = Request.new(self.collection_url, self, { :method => :post, :params => attribute_params })
        self.class.request_queue.queue(request)
        self.class.fetch_all
      end
    end

    def update
      run_callbacks :update do
        request = Request.new(self.element_url, self, { :method => :put, :params => attribute_params })
        self.class.request_queue.queue(request)
        self.class.fetch_all
      end
    end

    def destroy
      run_callbacks :destroy do
        request = Request.new(self.element_url, self, { :method => :delete })
        self.class.request_queue.queue(request)
        self.class.fetch_all
      end
    end

    def update_attributes(attributes={})
      attributes.each do |name, value|
        self.send("#{name}=", value)
      end
      request = Request.new(self.element_url, self, { :method => :put, :params => { self.class.element_name.to_sym => attributes } })
      self.class.request_queue.queue(request)
      self.class.fetch_all
    end

    def attribute_params
      { self.class.element_name.to_sym => changed_attributes.inject({}) do |hash, changed_attribute|
        hash.tap do |hash|
          hash[changed_attribute.first] = self.send(changed_attribute.first)
        end
      end }
    end
  end
end
