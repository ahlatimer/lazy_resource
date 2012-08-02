require 'spec_helper'

class Admin < User; end

describe LazyResource::Resource do
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

  describe '.find' do
    pending 'is a special case from the other finders (where, etc.) in that it returns only one object. I still haven\'t decided how I want to handle this.'
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
end
