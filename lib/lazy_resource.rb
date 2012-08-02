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
  
  autoload :Attributes
  autoload :Mapping
  autoload :Relation
  autoload :Request
  autoload :Resource
  autoload :ResourceQueue
  autoload :Types
  autoload :UrlGeneration

  def self.configure(&block)
    yield Resource
  end
end
