require 'active_model'
require 'active_support'
require 'json'
require 'typhoeus'

require 'active_support'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/kernel/reporting'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/object/duplicable'
require 'set'
require 'uri'

require 'active_support/core_ext/uri'

require 'lazy_resource/version'
require 'lazy_resource/errors'

module LazyResource
  extend ActiveSupport::Autoload
  
  autoload :ConfigurationDelegate
  autoload :Attributes
  autoload :Mapping
  autoload :Relation
  autoload :Request
  autoload :Resource
  autoload :ResourceQueue
  autoload :Types
  autoload :UrlGeneration

  def self.configure(&block)
    yield LazyResource::ConfigurationDelegate.new
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger
  end

  def self.debug=(debug)
    @debug = debug
  end

  def self.debug
    @debug = @debug.nil? ? false : @debug
  end

  def self.max_concurrency
    @max_concurrency ||= 200
  end

  def self.max_concurrency=(max)
    @max_concurrency = max
  end

  def self.deprecate(message, file, line)
    if self.logger && self.debug
      self.logger.info "#{message} from #{file}##{line}"
    end
  end
end
