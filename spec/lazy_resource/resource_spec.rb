require 'spec_helper'

class Admin < User; end

describe LazyResource::Resource do
  before :each do
    Thread.current[:request_queue].clear_stubs unless Thread.current[:request_queue].nil?
  end

  describe '#new' do
    it 'creates an object with the specified attributes' do
      user = User.new({ :name => 'Andrew', :id => 123 })
      user.name.should == 'Andrew'
      user.id.should == 123
    end
  end

  describe '#==' do
    it 'returns true if the objects have the same type and data' do
      user1 = User.new(:name => 'Andrew', :id => 123)
      user2 = User.new(:name => 'Andrew', :id => 123)
      user1.should == user2
    end

    it 'returns false if the objects do not have the same type' do
      user = User.new(:name => 'Andrew')
      admin = Admin.new(:name => 'Andrew')
      user.should_not == admin
    end

    it 'returns false if the objects do not have the same data' do
      user1 = User.new(:name => 'Andrew')
      user2 = User.new(:name => 'James')
      user1.should_not == user2
    end
  end

  describe '#eql?' do
    it 'returns true if the objects have the same type and data' do
      user1 = User.new(:name => 'Andrew', :id => 123)
      user2 = User.new(:name => 'Andrew', :id => 123)
      user1.eql?(user2).should == true
    end

    it 'returns false if the objects do not have the same type' do
      user = User.new(:name => 'Andrew')
      admin = Admin.new(:name => 'Andrew')
      user.eql?(admin).should == false
    end

    it 'returns false if the objects do not have the same data' do
      user1 = User.new(:name => 'Andrew')
      user2 = User.new(:name => 'James')
      user1.eql?(user2).should == false
    end
  end

  describe '#new_record?' do
    it 'returns true if the record is new' do
      user = User.new(:name => 'Andrew')
      user.new_record?.should == true
    end

    it 'returns false if the record is not new' do
      user = User.load(:name => 'Andrew')
      user.new_record?.should == false
    end
  end

  describe '#persisted?' do
    it 'returns true if the record is persisted (exists on the server)' do
      user = User.load(:name => 'Andrew')
      user.persisted?.should == true
    end

    it 'returns false if the record is not persisted' do
      user = User.new(:name => 'Andrew')
      user.persisted?.should == false
    end
  end

  describe '#save' do
    describe 'new record' do
      before :each do
        LazyResource::HttpMock.respond_to do |responder|
          responder.post('http://example.com/users', '{ "name": "Andrew" }')
        end
      end
      
      it 'calls #create' do
        user = User.new(:name => 'Andrew')
        user.should_receive(:create)
        user.save
      end
    end

    describe 'persisted record' do
      before :each do
        LazyResource::HttpMock.respond_to do |responder|
          responder.put('http://example.com/users/1', '{ "name": "Andrew" }')
        end
      end

      it 'calls #update' do
        user = User.load(:name => 'Andrew')
        user.name = 'James'
        user.should_receive(:update)
        user.save
      end
    end
  end

  describe '#create' do
    before :each do
      LazyResource::HttpMock.respond_to do |responder|
        responder.post('http://example.com/users', '{ "name": "Andrew" }')
      end
    end

    it 'issues a POST request with the set attributes' do
      user = User.new(:name => 'Andrew')
      params = ['http://example.com/users', user, {
        :method => :post,
        :params => { :user => { 'name' => 'Andrew' } }
      }]
      request = LazyResource::Request.new(*params)
      LazyResource::Request.should_receive(:new).with(*params).and_return(request)
      user.create
    end

    it 'resets the dirty attributes' do
      user = User.new(:name => 'Andrew')
      params = ['http://example.com/users', user, {
        :method => :post,
        :params => { :user => { 'name' => 'Andrew' } }
      }]
      user.create
      user.changed?.should == false
      user.changed_attributes.should == {}
    end
  end

  describe '#update' do
    before :each do
      LazyResource::HttpMock.respond_to do |responder|
        responder.put('http://example.com/users/1', '{ "name": "James" }')
      end
    end

    it 'issues a PUT request with the set attributes' do
      user = User.load(:name => 'Andrew', :id => 1)
      user.name = 'James'
      params = ['http://example.com/users/1', user, {
        :method => :put,
        :params => { :user => { 'name' => 'James' } }
      }]
      request = LazyResource::Request.new(*params)
      LazyResource::Request.should_receive(:new).with(*params).and_return(request)
      user.update
    end
  end

  describe '#destroy' do
    before :each do
      LazyResource::HttpMock.respond_to do |responder|
        responder.delete('http://example.com/users/1', '')
      end
    end

    it 'issues a DELETE request to the resource\'s element url' do
      user = User.load(:name => 'Andrew', :id => 1)
      params = ['http://example.com/users/1', user, {
        :method => :delete
      }]
      request = LazyResource::Request.new(*params)
      LazyResource::Request.should_receive(:new).with(*params).and_return(request)
      user.destroy
    end
  end

  describe '#update_attributes' do
    before :each do
      LazyResource::HttpMock.respond_to do |responder|
        responder.put('http://example.com/users/1', '')
      end
    end

    it 'issues a PUT request to the resource\'s element url with the updated attributes' do
      user = User.load(:name => 'Andrew', :id => 1)
      params = ['http://example.com/users/1', user, {
        :method => :put,
        :params => { :user => { 'name' => 'James' } }
      }]
      request = LazyResource::Request.new(*params)
      LazyResource::Request.should_receive(:new).with(*params).and_return(request)
      user.update_attributes(:name => 'James')
    end

    it 'updates the local attributes' do
      user = User.load(:name => 'Andrew', :id => 1)
      user.update_attributes(:name => 'James')
      user.name.should == 'James'
    end
  end

  describe '#attribute_params' do
    it 'returns a hash of all of the changed attributes' do
      user = User.new(:name => 'Andrew')
      user.attribute_params.should == { :user => { 'name' => 'Andrew' } }
    end
  end

  describe '#as_json' do
    it 'returns the resource as a hash' do
      user = User.load(:id => 1, :name => 'Andrew')
      user.as_json.should == { :id => 1, :name => 'Andrew' }
    end
  end

  describe '.find' do
    it 'generates a new resource and associated request and adds it to the request queue' do
      LazyResource::Request.should_receive(:new)
      User.request_queue.should_receive(:queue)
      user = User.find(1)
      user.fetched?.should == false
    end
  end

  describe '.where' do
    it 'creates a new relation with the passed where values' do
      users = User.where(:name => 'Andrew')
      users.where_values.should == { :name => 'Andrew' }
    end
  end

  describe '.order' do
    it 'creates a new relation with the passed order value' do
      users = User.order('created_at')
      users.order_value.should == 'created_at'
    end
  end
  
  describe '.limit' do
    it 'creates a new relation with the passed limit value' do
      users = User.limit(10)
      users.limit_value.should == 10
    end
  end

  describe '.offset' do
    it 'creates a new relation with the passed offset' do
      users = User.offset(10)
      users.offset_value.should == 10
    end
  end

  describe '.page' do
    it 'creates a new relation with the passed page' do
      users = User.page(3)
      users.page_value.should == 3
    end
  end

  describe '.create' do
    before :each do
      LazyResource::HttpMock.respond_to do |responder|
        responder.post 'http://example.com/users', '{ "name": "Andrew", "id": 1 }'
      end
    end

    it 'instantiates a new record with the passed values' do
      user = User.create(:name => 'Andrew')
      user.name.should == 'Andrew'
    end

    it 'issues a POST request with the passed parameters' do
      user = User.new(:name => 'Andrew')
      params = ['http://example.com/users', user, {
        :method => :post,
        :params => { :user => { 'name' => 'Andrew' } }
      }]
      request = LazyResource::Request.new(*params)
      LazyResource::Request.should_receive(:new).with(*params).and_return(request)
      User.create(:name => 'Andrew')
    end
  end

  describe '.site' do
    before :each do
      @site = User.site
    end

    after :each do
      User.site = @site
    end

    it 'returns the site if it is defined' do
      User.site = 'http://github.com'
      User.site.should == 'http://github.com'
    end

    it 'returns LazyResource::Resource.site if site is not defined' do
      User.send(:remove_instance_variable, "@site")
      User.site.should == LazyResource::Resource.site
    end
  end

  describe '.site=' do
    before :each do
      @site = User.site
    end

    after :each do
      User.site = @site
    end

    it 'sets the site' do
      User.site = 'http://github.com'
      User.site.should == 'http://github.com'
    end
  end

  describe '.resource_queue' do
    before :each do
      Thread.current[:request_queue] = nil
    end

    after :each do
      Thread.current[:resource_queue] = nil
    end

    it 'creates a new Hydra queue on the current thread' do
      Typhoeus::Hydra.should_receive(:new)
      User.request_queue.should == Thread.current[:request_queue]
    end
  end

  describe 'callbacks' do
    before :each do
      LazyResource::HttpMock.respond_to do |responder|
        responder.post('http://example.com/users', '')
        responder.put('http://example.com/users/1', '')
        responder.delete('http://example.com/users/1', '')
      end
    end

    describe 'create' do
      it 'adds a before_create callback' do
        User.respond_to?(:before_create).should == true
      end

      it 'adds a around_create callback' do
        User.respond_to?(:around_create).should == true
      end

      it 'adds a after_create callback' do
        User.respond_to?(:after_create).should == true
      end
    end

    describe 'update' do
      it 'adds a before_update callback' do
        User.respond_to?(:before_update).should == true
      end

      it 'adds a around_update callback' do
        User.respond_to?(:around_update).should == true
      end

      it 'adds a after_update callback' do
        User.respond_to?(:after_update).should == true
      end
    end

    describe 'save' do
      it 'adds a before_save callback' do
        User.respond_to?(:before_save).should == true
      end

      it 'adds a around_save callback' do
        User.respond_to?(:around_save).should == true
      end

      it 'adds a after_save callback' do
        User.respond_to?(:after_save).should == true
      end
    end

    describe 'destroy' do
      it 'adds a before_destroy callback' do
        User.respond_to?(:before_destroy).should == true
      end

      it 'adds a around_destroy callback' do
        User.respond_to?(:around_destroy).should == true
      end

      it 'adds a after_destroy callback' do
        User.respond_to?(:after_destroy).should == true
      end
    end
  end

  describe 'validations' do
    class User
      validates_presence_of :name
    end

    it 'validates' do
      user = User.new
      user.valid?.should == false
      user.name = 'Andrew'
      user.valid?.should == true
    end
  end
end
