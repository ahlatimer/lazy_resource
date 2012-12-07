module LazyResource
  module Resource
    extend ActiveSupport::Concern
    include ActiveModel::Conversion
    include Attributes, Mapping, Types, UrlGeneration

    included do
      extend ActiveModel::Callbacks
      define_model_callbacks :create, :update, :save, :destroy

      include ActiveModel::Validations
    end

    def self.site=(site)
      @site = site
    end

    def self.site
      @site
    end

    def self.default_headers=(headers)
      @default_headers = headers
    end

    def self.default_headers
      @default_headers || {}
    end

    def self.root_node_name=(node_name)
      LazyResource::Mapping.root_node_name = node_name
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
      # The site variable is required for LazyResources's mapping to work.
      def site=(site)
        @site = site
      end

      def default_headers
        if defined?(@default_headers)
          @default_headers
        else
          LazyResource::Resource.default_headers
        end
      end

      def default_headers=(headers)
        @default_headers = headers
      end

      def from
        @from
      end

      def from=(from)
        @from = from
      end

      def request_queue
        Thread.current[:request_queue] ||= Typhoeus::Hydra.new
      end

      def find(id, params={}, options={})
        self.new(self.primary_key_name => id).tap do |resource|
          resource.fetched = false
          resource.persisted = true
          request = Request.new(resource.element_url(params), resource, options)
          request_queue.queue(request)
        end
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

      def all
        Relation.new(self)
      end

      def create(attributes={})
        new(attributes).tap do |resource|
          resource.create
        end
      end
    end

    def initialize(attributes={})
      self.tap do |resource|
        resource.load(attributes, false)
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
        self.changed_attributes.clear
      end
    end

    def update
      run_callbacks :update do
        request = Request.new(self.element_url, self, { :method => :put, :params => attribute_params })
        self.class.request_queue.queue(request)
        self.class.fetch_all
        self.changed_attributes.clear
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
      self.update
    end

    def attribute_params
      { self.class.element_name.to_sym => changed_attributes.inject({}) do |hash, changed_attribute|
        hash.tap do |hash|
          hash[changed_attribute.first] = self.send(changed_attribute.first)
        end
      end }
    end

    def as_json(options={})
      self.class.attributes.inject({}) do |hash, (attribute_name, attribute_options)|
        attribute_type = attribute_options[:type]

        # Skip nil attributes (need to use instance_variable_get to avoid the stub relations that get added for associations."
        unless self.instance_variable_get("@#{attribute_name}").nil?
          value = self.send(:"#{attribute_name}")

          if (attribute_type.is_a?(::Array) && attribute_type.first.include?(LazyResource::Resource))
            value = value.map { |v| v.as_json }
          elsif attribute_type.include?(LazyResource::Resource)
            value = value.as_json
          elsif attribute_type == DateTime
            if options[:include_time_ago_in_words] && defined?(TwitterCldr)
              hash[:"#{attribute_name}_in_words"] = (DateTime.now - (DateTime.now - value).to_f).localize.ago.to_s
            end

            if options[:strftime]
              value = self.send(attribute_name).strftime(options[:strftime])
            end

            if options[attribute_name.to_sym] && options[attribute_name.to_sym][:strftime]
              value = self.send(attribute_name).strftime(options[attribute_name.to_sym][:strftime])
            end

            value = value.to_s unless value.is_a?(String)
          end

          hash[attribute_name.to_sym] = value
        end
        hash
      end
    end
  end
end
