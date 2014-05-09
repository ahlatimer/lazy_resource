require 'spec_helper'

describe LazyResource::LogSubscriber do
  let(:event) do
    OpenStruct.new({
      payload: {
        code: 200,
        time: 5,
        url: "http://google.com"
      }
    })
  end

  describe '#request' do
    subject { LazyResource::LogSubscriber.new }

    before do
      LazyResource::LogSubscriber.attach_to(:lazy_resource)

      subject.stub(:info) do |message|
        message
      end
    end

    it 'logs the request using the info level' do
      subject.should_receive(:info).with(any_args)
      subject.request(event)
    end

    it 'includes the response code' do
      subject.request(event).should =~ /200/
    end

    it 'includes the response time' do
      subject.request(event).should =~ /5000ms/
    end

    it 'includes the request url' do
      subject.request(event).should =~ /http:\/\/google\.com/
    end

    after do
      ActiveSupport::LogSubscriber.log_subscribers.clear
    end
  end
end
