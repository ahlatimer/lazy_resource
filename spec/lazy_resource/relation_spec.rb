require 'spec_helper'

describe LazyResource::Relation do
  describe '#new' do
    it 'adds itself to the resource queue' do
      users = LazyResource::Relation.new(User)
      users.resource_queue.instance_variable_get("@queue").include?(users).should == true
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

  describe '.resource_queue' do
    it 'creates a new resource queue if one does not already exist' do
      LazyResource::Relation.resource_queue.should_not be_nil
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
end
