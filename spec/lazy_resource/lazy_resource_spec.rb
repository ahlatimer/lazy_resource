require 'spec_helper'

class DumbLogger
  def info(msg)
    puts msg
  end
end

describe LazyResource do
  before :each do
    LazyResource.configure do |config|
      config.debug = true
      config.logger = DumbLogger.new
    end
  end

  describe '#logger' do
    it 'returns the logger' do
      LazyResource.logger.should_not be_nil
    end
  end

  describe '#debug' do
    it 'logs when a request completes' do
      LazyResource.logger.should_receive(:info)
      request = LazyResource::Request.new('http://example.com', User.new)
      request.response = Typhoeus::Response.new
      request.execute_callbacks
    end
  end
end
