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
      ActiveSupport::Notifications.should_receive(:instrument).with('request.lazy_resource', kind_of(Hash))
      request = LazyResource::Request.new('http://example.com', User.new)
      request.response = Typhoeus::Response.new
      request.execute_callbacks
    end
  end

  describe '#deprecate' do
    it 'logs a message about a deprecation' do
      LazyResource.logger.should_receive(:info).with("a deprecation from file.rb#123")
      LazyResource.deprecate('a deprecation', 'file.rb', 123)
    end
  end

  describe '#max_concurrency=' do
    it 'sets the max_concurrency' do
      LazyResource.max_concurrency = 100
      LazyResource.max_concurrency.should == 100
    end
  end

  describe '#max_concurrency' do
    before :each do
      Thread.current[:request_queue] = nil
    end

    it 'determines the amount of maximum concurrent requests Hydra will make' do
      LazyResource.max_concurrency = 100
      User.request_queue.max_concurrency.should == 100
    end
  end
end
