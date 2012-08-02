require 'spec_helper'

describe LazyResource::Collection do
  describe '#new' do
    it 'creates a collection with the objects specified' do
      users = [User.new({ :name => 'Andrew' }), User.new({ :name => 'James' })]
      users_collection = LazyResource::Collection.new(User, users)
      users_collection.to_a.should == users
    end
  end

  describe '#load' do
    it 'loads the objects passed' do
      users = [{ :id => '1', :name => 'Andrew' }, { :id => '1', :name => 'James' }]
      users_collection = LazyResource::Collection.new(User)
      users_collection.load(users)
      users_collection.to_a.should == User.load(users)
    end
  end
end
