require 'spec_helper'

class AttributeObject
  include LazyResource::Attributes

  attr_accessor :fetched

  def self.resource_queue
    @resource_queue ||= LazyResource::ResourceQueue.new
  end

  def self.request_queue
    @request_queue ||= Typhoeus::Hydra.new
  end

  def fetched?
    @fetched
  end

  def element_name
    "attribute_object"
  end

  def id
    1
  end
end

describe LazyResource::Attributes do
  before :each do
    AttributeObject.attribute(:name, String)
    @foo = AttributeObject.new
  end
  
  describe '.attribute' do
    it 'adds the attribute to the attributes hash' do
      AttributeObject.attributes[:name].should == { :type => String, :options => {} }
    end
    
    it 'creates a getter method' do
      @foo.respond_to?(:name).should == true
    end

    it 'creates a setter method' do
      @foo.respond_to?(:name=).should == true
    end

    it 'creates a question method' do
      @foo.respond_to?(:name?).should == true
    end

    describe 'getter' do
      it 'runs fetch_all if the current object is not fetched' do
        @foo.fetched = false
        AttributeObject.should_receive(:fetch_all)
        @foo.name
      end

      it 'does not run fetch_all if the current object is fetched' do
        @foo.fetched = true
        AttributeObject.should_not_receive(:fetch_all)
        @foo.name
      end

      describe 'associations' do
        before :each do
          AttributeObject.attribute(:posts, [Post])
          AttributeObject.attribute(:user, User)
        end

        it 'returns a relation with the specified where values' do
          Post.should_receive(:where).with(:attribute_object_id => 1)
          @foo.fetched = false
          @foo.posts
        end

        it 'finds a singular resource' do
          User.should_receive(:where).with(:attribute_object_id => 1)
          @foo.fetched = false
          @foo.user
        end

        describe ':using' do
          before :each do
            AttributeObject.attribute(:posts_url, String)
            AttributeObject.attribute(:user_url, String)
            AttributeObject.attribute(:posts, [Post], :using => :posts_url)
            AttributeObject.attribute(:user, User, :using => :user_url)
            @foo.send(:instance_variable_set, "@posts_url", 'http://example.com/path/to/posts')
            @foo.send(:instance_variable_set, "@user_url", 'http://example.com/path/to/user')
          end

          it 'finds a collection using the specified url' do
            relation = LazyResource::Relation.new(Post, :headers => {})
            request = LazyResource::Request.new(@foo.posts_url, relation)
            LazyResource::Request.should_receive(:new).with(@foo.posts_url, relation, :headers => relation.headers).and_return(request)
            LazyResource::Relation.should_receive(:new).with(Post, :fetched => true).and_return(relation)
            @foo.class.request_queue.should_receive(:queue).with(request)
            @foo.fetched = false
            @foo.posts
          end

          it 'finds a singular resource with the specified url' do
            resource = User.load({})
            request = LazyResource::Request.new(@foo.user_url, resource)
            LazyResource::Request.should_receive(:new).with(@foo.user_url, resource).and_return(request)
            @foo.class.request_queue.should_receive(:queue).with(request)
            @foo.fetched = false
            @foo.user
          end
        end
      end
    end
  end

  describe '.primary_key_name' do
    after :all do
      AttributeObject.primary_key_name = 'id'
    end

    it 'defaults to id' do
      AttributeObject.primary_key_name.should == 'id'
    end

    it 'returns the primary_key_name instance variable' do
      AttributeObject.primary_key_name.should == AttributeObject.instance_variable_get("@primary_key_name")
    end
  end

  describe '.primary_key_name=' do
    after :all do
      AttributeObject.primary_key_name = 'id'
    end

    it 'sets the primary_key_name' do
      AttributeObject.primary_key_name = 'name'
      AttributeObject.instance_variable_get("@primary_key_name").should == 'name'
    end
  end

  describe '.attributes' do
    it 'returns a hash of the defined attributes' do
      AttributeObject.attributes.should == { :name => { :type => String, :options => {} },
                                             :posts => { :type => [Post], :options => { :using => :posts_url } },
                                             :user => { :type => User, :options => { :using => :user_url } },
                                             :posts_url => { :type => String, :options => {} },
                                             :user_url => { :type => String, :options => {} } }
    end
  end

  describe '#primary_key' do
    it 'returns the value at the primary_key_name' do
      obj = AttributeObject.new
      obj.primary_key.should == obj.send(AttributeObject.primary_key_name)
    end
  end
end
