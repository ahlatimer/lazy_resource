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
      end
    end
  end

  describe '.attributes' do
    it 'returns a hash of the defined attributes' do
      AttributeObject.attributes.should == { :name => { :type => String, :options => {} }, :posts => { :type => [Post], :options => {} }, :user => { :type => User, :options => {} } }
    end
  end
end
