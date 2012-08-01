require 'spec_helper'

describe LazyResource::Resource do
  describe '#new' do
    it 'creates an object with the specified attributes' do
      user = User.new({ :name => 'Andrew', :id => 123 })
      user.name.should == 'Andrew'
      user.id.should == 123
    end
  end
end
