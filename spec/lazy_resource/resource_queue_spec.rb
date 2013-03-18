require 'spec_helper'

describe LazyResource::ResourceQueue do
  before :each do
    @queue = LazyResource::ResourceQueue.new
    @relation = LazyResource::Relation.new(User)
  end

  after :each do
    Thread.current[:request_queue] = nil
    @queue.flush!
  end

  describe '#queue' do
    it 'queues a relation' do
      @queue.queue(@relation)
      @queue.instance_variable_get("@queue").should include(@relation)
    end
  end

  describe '#flush!' do
    it 'flushes the request queue without processing any of the resources' do
      LazyResource::Request.should_not_receive(:new)
      @queue.queue(@relation)
      @queue.flush!
      @queue.instance_variable_get("@queue").should == []
    end
  end

  describe '#request_queue' do
    it 'creates a new Hydra queue on the current thread' do
      Typhoeus::Hydra.should_receive(:new)
      @queue.request_queue.should == Thread.current[:request_queue]
    end
  end

  describe '#run' do
    before :each do
      LazyResource::HttpMock.respond_to do |responder|
        responder.get('http://example.com/users', '')
      end
    end

    it 'sends the requests to the request queue and runs the request queue' do
      @queue.queue(@relation)
      @queue.should_receive(:send_to_request_queue!)
      @queue.request_queue.stub(:items_queued?).and_return(true)
      @queue.request_queue.should_receive(:run)
      @queue.run
    end
  end

  describe '#send_to_request_queue!' do
    it 'creates requests for the relations in the queue and puts them in the request_queue' do
      @queue.request_queue.should_receive(:queue)
      @queue.queue(@relation)
      @queue.send_to_request_queue!
      @queue.instance_variable_get("@queue").should == []
    end
  end

  describe '#url_for' do
    it 'creates a URL for the given resource' do
      @queue.url_for(@relation).should == 'http://example.com/users'
    end

    it 'respects the "from" option when set on a Relation object' do
      @relation.from = 'people'
      @queue.url_for(@relation).should == 'http://example.com/people'
    end

    it 'respects the "from" option when set on a Resource class' do
      User.from = 'people'
      @queue.url_for(@relation).should == 'http://example.com/people'
      User.from = nil
    end
  end
end
