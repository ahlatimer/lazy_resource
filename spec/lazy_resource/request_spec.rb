require 'spec_helper'

class SampleResource
  include LazyResource::Resource

  attribute :id, Fixnum
  attribute :name, String
  attribute :created_at, DateTime
end

describe LazyResource::Request do
  describe '#new' do
    before :each do
      LazyResource::HttpMock.respond_to do |responder|
        responder.get('http://example.com/api', '')
      end
    end

    after :each do
      Thread.current[:default_headers] = nil
      Thread.current[:default_params] = nil
    end

    it 'sets a default Accept header of application/json' do
      request = LazyResource::Request.new('http://example.com/api', nil)
      request.options[:headers][:Accept].should == 'application/json'
    end

    it 'sets the default method of GET' do
      request = LazyResource::Request.new('http://example.com/api', nil)
      request.options[:method].should == :get
    end

    it 'merges the headers from the current thread' do
      Thread.current[:default_headers] = { :"X-Access-Token" => 'abc' }
      request = LazyResource::Request.new('http://example.com/api', nil)
      request.options[:headers][:"X-Access-Token"].should == 'abc'
    end

    it 'merged the params from the current thread' do
      Thread.current[:default_params] = { :"access_token" => 'abc' }
      request = LazyResource::Request.new('https://example.com/api', nil)
      request.options[:params][:"access_token"].should == 'abc'
    end
  end

  describe '#parse' do
    describe 'single resources' do
      it 'parses JSON and loads it onto the resource' do
        request = LazyResource::Request.new('http://example.com', SampleResource.new)
        response_options = { 
          :code => 200, 
          :body => { 
            :id => 1,
            :name => "Andrew", 
            :created_at => "2012-08-01 00:00:00 -0500" 
          }.to_json, 
          :time => 0.3
        }
        response = Typhoeus::Response.new(response_options)
        request.response = response
        request.parse
        request.resource.id.should == 1
        request.resource.name.should == 'Andrew'
        request.resource.created_at.should == DateTime.parse("2012-08-01 00:00:00 -0500")
      end
    end

    describe 'resource collections' do
      it 'parses JSON and loads it onto the resource' do
        request = LazyResource::Request.new('http://example.com', LazyResource::Relation.new(SampleResource))
        response_options = {
          :code => 200,
          :body => [{
            :id => 1,
            :name => 'Andrew',
            :created_at => '2012-08-01 00:00:00 -0500'
          }, {
            :id => 2,
            :name => 'James',
            :created_at => '2012-07-01 00:00:00 -0500'
          }].to_json,
          :time => 0.3
        }
        response = Typhoeus::Response.new(response_options)
        request.response = response
        request.parse
        users = request.resource.to_a
        users.map(&:id).should == [1,2]
        users.map(&:name).should == ['Andrew', 'James']
        users.map(&:created_at).should == [DateTime.parse('2012-08-01 00:00:00 -0500'), DateTime.parse('2012-07-01 00:00:00 -0500')]
      end
    end
  end

  describe '#handle_errors' do
    [
      [301, LazyResource::Redirection],
      [400, LazyResource::BadRequest],
      [401, LazyResource::UnauthorizedAccess],
      [403, LazyResource::ForbiddenAccess],
      [404, LazyResource::ResourceNotFound],
      [405, LazyResource::MethodNotAllowed],
      [409, LazyResource::ResourceConflict],
      [410, LazyResource::ResourceGone],
      [422, LazyResource::UnprocessableEntity],
      [500, LazyResource::ServerError]
    ].each do |error|
      describe "status: #{error[0]}" do
        it "raises #{error[1]}" do
          request = LazyResource::Request.new('http://example.com', nil)
          response = Typhoeus::Response.new(:code => error[0], :headers => {}, :body => '', :time => 0.3)
          request.response = response
          lambda { request.handle_errors }.should raise_error(error[1])
        end
      end
    end

    describe 'status: 4xx' do
      it 'raises ClientError' do
        request = LazyResource::Request.new('http://example.com', nil)
        response = Typhoeus::Response.new(:code => 402, :headers => {}, :body => '', :time => 0.3)
        request.response = response
        lambda { request.handle_errors }.should raise_error(LazyResource::ClientError)
      end
    end
  end
end
