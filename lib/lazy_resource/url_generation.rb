module LazyResource
  module UrlGeneration
    extend ActiveSupport::Concern

    def element_path(options = nil)
      self.class.element_path(to_param, options || prefix_options)
    end

    def new_element_path
      self.class.new_element_path(prefix_options)
    end

    def collection_path(options = nil)
      self.class.collection_path(options || prefix_options)
    end

    def split_options(options = {})
      self.class.split_options(options)
    end
    
    module ClassMethods
      # Gets the \prefix for a resource's nested URL (e.g., <tt>prefix/collectionname/1</tt>)
      def prefix(options={})
        path = '/'
        options = options.to_a.uniq
        path = options.inject(path) do |uri, option|
          key, value = option[0].to_s, option[1]
          uri << ActiveSupport::Inflector.pluralize(key.gsub("_id", ''))
          uri << "/#{value}/"
        end
      end

      
      # Gets the element path for the given ID in +id+. If the +query_options+ parameter is omitted, Rails
      # will split from the \prefix options.
      #
      # ==== Options
      # +prefix_options+ - A \hash to add a \prefix to the request for nested URLs (e.g., <tt>:account_id => 19</tt>
      # would yield a URL like <tt>/accounts/19/purchases.json</tt>).
      #
      # +query_options+ - A \hash to add items to the query string for the request.
      def element_path(id, prefix_options = {}, query_options = nil, from = nil)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "#{prefix(prefix_options)}#{from || collection_name}/#{URI.escape id.to_s}#{query_string(query_options)}"
      end

      # Gets the new element path for REST resources.
      #
      # ==== Options
      # * +prefix_options+ - A hash to add a prefix to the request for nested URLs (e.g., <tt>:account_id => 19</tt>
      # would yield a URL like <tt>/accounts/19/purchases/new.json</tt>).
      def new_element_path(prefix_options = {})
        "#{prefix(prefix_options)}#{collection_name}/new"
      end

      # Gets the collection path for the REST resources. If the +query_options+ parameter is omitted, Rails
      # will split from the +prefix_options+.
      #
      # ==== Options
      # * +prefix_options+ - A hash to add a prefix to the request for nested URLs (e.g., <tt>:account_id => 19</tt>
      #   would yield a URL like <tt>/accounts/19/purchases.json</tt>).
      # * +query_options+ - A hash to add items to the query string for the request.
      def collection_path(prefix_options = {}, query_options = nil, from = nil)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "#{prefix(prefix_options)}#{from || collection_name}#{query_string(query_options)}"
      end

      def check_prefix_options(prefix_options)
        p_options = HashWithIndifferentAccess.new(prefix_options)
        prefix_parameters.each do |p|
          raise(MissingPrefixParam, "#{p} prefix_option is missing") if p_options[p].blank?
        end
      end
      
      # contains a set of the current prefix parameters.
      def prefix_parameters
        @prefix_parameters ||= prefix_source.scan(/:\w+/).map { |key| key[1..-1].to_sym }.to_set
      end

      # Builds the query string for the request.
      def query_string(options)
        "?#{options.to_query}" unless options.nil? || options.empty?
      end

      # split an option hash into two hashes, one containing the prefix options,
      # and the other containing the leftovers.
      def split_options(options = {})
          prefix_options, query_options = {}, {}

          (options || {}).each do |key, value|
            next if key.blank?
            (key =~ /\w*_id/ ? prefix_options : query_options)[key.to_sym] = value
          end

          [prefix_options, query_options]
      end
    end
  end
end

