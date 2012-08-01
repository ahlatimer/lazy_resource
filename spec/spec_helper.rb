require 'rubygems'
require 'bundler/setup'

require 'lazy_resource'

require 'fixtures/comment'
require 'fixtures/post'
require 'fixtures/user'

module LazyResource
  autoload :HttpMock
end

RSpec.configure do |config|
end
