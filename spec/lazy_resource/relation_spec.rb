require 'spec_helper'

describe LazyResource::Relation do
  before :each do
    LazyResource::HttpMock.respond_to do |responder|
      responder.get('http://example.com', '')
      responder.get('http://example.com/users', '')
    end
  end

  describe '#new' do
    it 'adds itself to the resource queue' do
      users = LazyResource::Relation.new(User)
      users.resource_queue.instance_variable_get("@queue").include?(users).should == true
    end

    it 'does not add itself to the resource queue if fetched' do
      users = LazyResource::Relation.new(User, :fetched => true)
      users.resource_queue.instance_variable_get("@queue").include?(users).should_not == true
    end
  end

  describe '#load' do
    it 'loads the objects passed' do
      users = [{ :id => '1', :name => 'Andrew' }, { :id => '1', :name => 'James' }]
      users_collection = LazyResource::Relation.new(User)
      users_collection.load(users)
      users_collection.to_a.should == User.load(users)
    end
  end

  describe '#as_json' do
    it 'returns the relation as an array of hashes' do
      users = [User.load(:id => 1, :name => 'Andrew'), User.load(:id => 2, :name => 'James')]
      users_collection = LazyResource::Relation.new(User, :fetched => true)
      users_collection.load(users)
      users_collection.as_json.should == [{ :id => 1, :name => 'Andrew' }, { :id => 2, :name => 'James' }]
    end
  end

  describe '.resource_queue' do
    it 'creates a new resource queue if one does not already exist' do
      LazyResource::Relation.resource_queue.should_not be_nil
    end
  end

  describe '#collection_name' do
    it 'should return the collection name from the klass' do
      relation = LazyResource::Relation.new(User)
      relation.collection_name.should == User.collection_name
    end
  end

  describe '#where' do
    it 'sets the where values if none exist' do
      relation = LazyResource::Relation.new(User)
      relation.where(:name => 'Andrew')
      relation.where_values.should == { :name => 'Andrew' }
    end

    it 'merges where values' do
      relation = LazyResource::Relation.new(User, :where_values => { :id => 123 })
      relation.where(:name => 'Andrew')
      relation.where_values.should == { :id => 123, :name => 'Andrew' }
    end

    it 'overwrites values' do
      relation = LazyResource::Relation.new(User, :where_values => { :name => 'Andrew' })
      relation.where(:name => 'James')
      relation.where_values.should == { :name => 'James' }
    end
  end

  describe '#order' do
    it 'sets the order value if none exists' do
      relation = LazyResource::Relation.new(User)
      relation.order('created_at')
      relation.order_value.should == 'created_at'
    end

    it 'overwrites the order value' do
      relation = LazyResource::Relation.new(User, :order_value => 'created_at')
      relation.order('name')
      relation.order_value.should == 'name'
    end
  end

  describe '#limit' do
    it 'sets the limit value if none exists' do
      relation = LazyResource::Relation.new(User)
      relation.limit(10)
      relation.limit_value.should == 10
    end

    it 'overwrites the order value' do
      relation = LazyResource::Relation.new(User, :limit_value => 10)
      relation.limit(100)
      relation.limit_value.should == 100
    end
  end

  describe '#offset' do
    it 'sets the offset value if none exists' do
      relation = LazyResource::Relation.new(User)
      relation.offset(10)
      relation.offset_value.should == 10
    end

    it 'overwrites the limit value' do
      relation = LazyResource::Relation.new(User, :offset_value => 10)
      relation.offset(20)
      relation.offset_value.should == 20
    end
  end

  describe '#page' do
    it 'sets the page value if none exists' do
      relation = LazyResource::Relation.new(User)
      relation.page(10)
      relation.page_value.should == 10
    end

    it 'overwrites the page value' do
      relation = LazyResource::Relation.new(User, :page_value => 10)
      relation.page(20)
      relation.page_value.should == 20
    end
  end

  describe 'chaining' do
    it 'supports chaining' do
      relation = LazyResource::Relation.new(User)
      relation.where(:name => 'Andrew').order('created_at').limit(10).offset(10).page(10)
      relation.where_values.should == { :name => 'Andrew' }
      relation.order_value.should == 'created_at'
      relation.limit_value.should == 10
      relation.offset_value.should == 10
      relation.page_value.should == 10
    end
  end

  describe '#to_params' do
    it 'wraps up the where, order, limit, offset, and page values into a hash' do
      params = { :where_values => { :name => 'Andrew' }, :order_value => 'created_at', :limit_value => 10, :offset_value => 10, :page_value => 10 }
      relation = LazyResource::Relation.new(User, params)
      relation.to_params.should == { :name => 'Andrew', :order => 'created_at', :limit => 10, :offset => 10, :page => 10 }
    end
  end

  describe '#respond_to?' do
    it 'returns true if array responds to the method' do
      relation = LazyResource::Relation.new(User)
      relation.respond_to?(:[]).should == true
    end
  end
end
