require 'spec_helper'

class SimpleLogger
  def info(msg)
    msg
  end
end

describe Typhoeus::Hydra do
  describe '#run_with_logging' do
    before :each do
      LazyResource.debug = true
      LazyResource.logger = SimpleLogger.new
      @hydra = Typhoeus::Hydra.new
      @hydra.stub!(:run_without_logging)
      @multi = @hydra.send(:instance_variable_get, :"@multi")
    end

    it 'logs if logging is enabled, there are items to process, and the queue has not yet started processing' do
      @multi.stub!(:easy_handles).and_return([1,2,3])
      @multi.stub!(:running_count).and_return(0)
      LazyResource.logger.should_receive(:info).twice
      @hydra.run_with_logging
    end

    it 'does not log if there are no items to process' do
      @multi.stub!(:easy_handles).and_return([])
      @multi.stub!(:running_count).and_return(0)
      LazyResource.logger.should_not_receive(:info)
      @hydra.run_with_logging
    end

    it 'does not log if the queue is already being processed' do
      @multi.stub!(:easy_handles).and_return([1,2,3])
      @multi.stub!(:running_count).and_return(3)
      LazyResource.logger.should_not_receive(:info)
      @hydra.run_with_logging
    end
  end
end
