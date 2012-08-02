require 'active_model'
require 'active_support'
require 'json'
require 'typhoeus'

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
end
