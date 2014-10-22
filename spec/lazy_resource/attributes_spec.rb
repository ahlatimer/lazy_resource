require 'spec_helper'

# We need a reference to this exact proc in two spots
LAMBDA_ROUTE = lambda { "/path/to/#{name}" }

class AttributeObject
  include LazyResource::Attributes

  attr_accessor :fetched, :request_error

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

      it 'raises the error at request_error if it exists' do
        @foo.request_error = StandardError.new
        lambda { @foo.name }.should raise_error(StandardError)
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

        context ':route' do
          before :each do
            AttributeObject.attribute(:posts_url, String)
            AttributeObject.attribute(:posts, [Post], :route => :posts_url)
            AttributeObject.attribute(:user, User, :route => "/path/to/user")
            @foo.send(:instance_variable_set, "@posts_url", '/path/to/posts')
          end

          it 'finds a collection using the specified url' do
            @foo.posts.route.should == '/path/to/posts'
          end

          it 'finds a singular resource with the specified url' do
            @foo.user.route.should == '/path/to/user'
          end

          context 'as a proc' do
            before :each do
              AttributeObject.any_instance.stub(:name).and_return("foobar")
              AttributeObject.attribute(:comments, [Post], :route => LAMBDA_ROUTE)
            end

            it 'evaluates the proc to generate the url' do
              @foo.comments.route.should == '/path/to/foobar'
            end
          end
        end

        context ':using' do
          after :all do
            AttributeObject.attribute(:posts_url, String)
            AttributeObject.attribute(:user_url, String)
            AttributeObject.attribute(:posts, [Post], :route => :posts_url)
            AttributeObject.attribute(:user, User, :route => :user_url)
          end

          it 'generates a deprecation warning when using :using' do
            LazyResource.should_receive(:deprecate).with("Attribute option :using is deprecated. Please use :route instead.", anything, anything)
            AttributeObject.attribute(:posts, [Post], :using => :posts_url)
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
                                             :posts => { :type => [Post], :options => { :route => :posts_url } },
                                             :user => { :type => User, :options => { :route => :user_url } },
                                             :posts_url => { :type => String, :options => {} },
                                             :user_url => { :type => String, :options => {} },
                                             :comments => { :type => [Post], :options => { :route => LAMBDA_ROUTE } } }
    end
  end

  describe '#primary_key' do
    it 'returns the value at the primary_key_name' do
      obj = AttributeObject.new
      obj.primary_key.should == obj.send(AttributeObject.primary_key_name)
    end
  end
end
