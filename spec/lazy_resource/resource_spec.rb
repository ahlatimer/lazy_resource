require 'spec_helper'

describe LazyResource::Resource do
  describe '.load' do
    before :each do 
      @now = Time.now
      @post = Post.new({ :title => 'Lorem Ipsum' })
      @comments = [Comment.new({ :body => "Lorem Ipsum" }), Comment.new({ :body => "Lorem Ipsum" })]
    end

    it 'loads single objects' do
      user = User.load({
        :id => 123, 
        :name => 'Andrew',
        :created_at => @now,
        :post => @post,
        :comments => @comments
      })

      user.id.should == 123
      user.name.should == 'Andrew'
      user.created_at.should == @now
      user.post.should == @post
      user.comments.should == @comments
    end

    it 'loads an array of objects' do
      users = User.load([
        {
          :id => 123
        },
        {
          :id => 123
        }
      ])

      users.each do |user|
        user.id.should == 123
      end
    end
  end

  describe '#load' do
    before :each do 
      @now = Time.now
      @post = Post.new({ :title => 'Lorem Ipsum' })
      @comments = [Comment.new({ :body => "Lorem Ipsum" }), Comment.new({ :body => "Lorem Ipsum" })]
    end

    it 'loads attributes' do
      user = User.new
      user.load({ :name => 'Bob' })
      user.name.should == 'Bob'
    end

    it 'overwrites existing attributes' do
      user = User.new({ :name => 'Andrew' })
      user.load({ :name => 'Bob' })
      user.name.should == 'Bob'
    end
  end

  describe '#new' do
    it 'creates an object with the specified attributes' do
      user = User.new({ :name => 'Andrew', :id => 123 })
      user.name.should == 'Andrew'
      user.id.should == 123
    end
  end
end
