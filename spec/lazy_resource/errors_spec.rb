require 'spec_helper'

describe LazyResource::ConnectionError do
  describe '#to_s' do
    it 'prints a message with the response code and message' do
      error = LazyResource::ConnectionError.new(Typhoeus::Response.new(:code => 300, :body => 'redirect'))
      error.to_s.should match(/300/)
      error.to_s.should match(/redirect/)
    end
  end
end

describe LazyResource::Redirection do
  describe '#to_s' do
    it 'prints the response\'s redirection location' do
      error = LazyResource::Redirection.new(Typhoeus::Response.new(:code => 300, :body => 'redirect', :headers => { :Location => 'http://example.com' }))
      error.to_s.should match(/example\.com/)
    end
  end
end

describe LazyResource::MethodNotAllowed do
  describe '#allowed_methods' do
    it 'prints the allowed methods' do
      error = LazyResource::MethodNotAllowed.new(Typhoeus::Response.new(:code => 405, :headers => { 'Allow' => 'put' }))
      error.allowed_methods.should == [:put]
    end
  end
end

describe LazyResource::TimeoutError do
  describe '#new' do
    it 'only accepts a message' do
      error = LazyResource::TimeoutError.new('timed out')
      error.to_s.should == 'timed out'
    end
  end
end

describe LazyResource::SSLError do
  describe '#new' do
    it 'only accepts a message' do
      error = LazyResource::SSLError.new('timed out')
      error.to_s.should == 'timed out'
    end
  end
end

