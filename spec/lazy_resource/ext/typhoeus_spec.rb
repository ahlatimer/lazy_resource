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
      @multi.send(:instance_variable_set, "@active", 10)
      @multi.send(:instance_variable_set, "@running", 0)
      LazyResource.logger.should_receive(:info).twice
      @hydra.run_with_logging
    end

    it 'does not log if there are no items to process' do
      @multi.send(:instance_variable_set, "@active", 0)
      @multi.send(:instance_variable_set, "@running", 0)
      LazyResource.logger.should_not_receive(:info)
      @hydra.run_with_logging
    end

    it 'does not log if the queue is already being processed' do
      @multi.send(:instance_variable_set, "@active", 10)
      @multi.send(:instance_variable_set, "@running", 5)
      LazyResource.logger.should_not_receive(:info)
      @hydra.run_with_logging
    end
  end
end
