require 'spec_helper'

class SimpleLogger
  def info(msg)
    msg
  end
end

describe "Logging added to Typhoeus" do
  before :each do
    LazyResource.debug = true
    LazyResource.logger = SimpleLogger.new
    @hydra = Thread.current[:request_queue] = Typhoeus::Hydra.new(:max_concurrency => LazyResource.max_concurrency)

    LazyResource::HttpMock.respond_to do |responder|
      responder.get('http://example.com', '')
      responder.get('http://example.com/users/1', { :name => 'Andrew' }.to_json)
    end
  end

  describe '#run_with_logging' do
    before :each do
      @hydra.stub!(:run_without_logging)
      @multi = @hydra.send(:instance_variable_get, :"@multi")
    end

    it 'logs if logging is enabled, there are items to process, and the queue has not yet started processing' do
      @multi.stub(:easy_handles).and_return([1,2,3])
      @multi.stub(:running_count).and_return(0)
      ActiveSupport::Notifications.should_receive(:instrument).twice
      @hydra.run_with_logging
    end

    it 'does not log if there are no items to process' do
      @multi.stub(:easy_handles).and_return([])
      @multi.stub(:running_count).and_return(0)
      ActiveSupport::Notifications.should_not_receive(:instrument)
      @hydra.run_with_logging
    end

    it 'does not log if the queue is already being processed' do
      @multi.stub(:easy_handles).and_return([1,2,3])
      @multi.stub(:running_count).and_return(3)
      ActiveSupport::Notifications.should_not_receive(:instrument)
      @hydra.run_with_logging
    end
  end

  describe '#items_queued?' do
    it 'returns true if there are items queued' do
      3.times { User.find(1) }
      @hydra.items_queued?.should == true
    end
  end

  describe 'logging' do
    it 'logs if logging is enabled, there are items to process, and the queue has not yet started processing' do
      users = []
      3.times { users << User.find(1) }
      # twice for the start/end, and once each for every user (3)
      ActiveSupport::Notifications.should_receive(:instrument).exactly(5).times
      users.each { |u| u.name }
    end

    it 'does not log if there are no items to process' do
      users = User.find(1)
      users.name
      ActiveSupport::Notifications.should_not_receive(:instrument)
    end
  end
end
