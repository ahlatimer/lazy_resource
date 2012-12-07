require 'spec_helper'

class Foo
  include LazyResource::Mapping
  include LazyResource::Types

  attr_accessor :id, :name, :created_at, :post, :comments, :comments_text

  def self.attributes
    @attributes ||= {
      :id => { :type => Fixnum },
      :name => { :type => String },
      :created_at => { :type => DateTime },
      :post => { :type => Bar },
      :comments => { :type => [Buzz] },
      :comments_text => { :type => [String] }
    }
  end
end

class Bar
  include LazyResource::Mapping
  include LazyResource::Types

  attr_accessor :title

  def self.attributes
    @attributes ||= {
      :title => { :type => String }
    }
  end
end

class Buzz
  include LazyResource::Mapping
  include LazyResource::Types

  attr_accessor :body

  def self.attributes
    @attributes ||= {
      :body => { :type => String }
    }
  end
end

describe LazyResource::Mapping do
  describe '.load' do
    before :each do 
      @now = DateTime.now
      @now_as_sting = @now.to_s
      @post = Bar.new
      @post.title = "Lorem Ipsum"
      @comments = []
      4.times do
        comment = Buzz.new
        comment.body = "Lorem Ipsum"
        @comments << comment
      end
    end

    it 'loads single objects' do
      user = Foo.load({
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
      user.comments.to_a.should == @comments
    end

    it 'loads an array of objects' do
      users = Foo.load([
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

  describe '.root_node_name' do
    after :each do
      LazyResource::Mapping.root_node_name = nil
      Foo.root_node_name = nil
    end

    it 'defaults to nil' do
      Foo.root_node_name.should == nil
    end

    it 'specifies the root node name' do
      Foo.root_node_name = :data
      Foo.root_node_name.should == :data
    end

    it 'maps the object at that value' do
      Foo.root_node_name = :data
      user = Foo.load({ 'data' => { :id => 123 } })
      user.id.should == 123
    end

    it 'maps objects without root node names, even if a root node name is defined' do
      Foo.root_node_name = :data
      user = Foo.load({ :id => 123 })
      user.id.should == 123
    end

    it 'maps collections at the root node name' do
      Foo.root_node_name = :data
      users = Foo.load({ 'data' => [{ :id => 123 }, { :id => 124 }]})
      users.map(&:id).should == [123,124]
    end

    it 'maps collections without root node names, even if a root node name is defined' do
      Foo.root_node_name = :data
      users = Foo.load([{ :id => 123 }, { :id => 124 }])
      users.map(&:id).should == [123,124]
    end
    
    it 'looks in the module for the root node name' do
      LazyResource::Mapping.root_node_name = :data
      Foo.root_node_name.should == :data
    end

    it 'handles root node names that are strings or symbols' do
      Foo.root_node_name = :data
      user = Foo.load('data' => { :id => 123 })
      user.id.should == 123
      Foo.root_node_name = 'data'
      user = Foo.load('data' => { :id => 123 })
      user.id.should == 123
    end

    it 'sets any other attributes in the hash to #other_attributes for a single resource' do
      Foo.root_node_name = :data
      user = Foo.load('data' => { :id => 123 }, 'length' => 12)
      user.other_attributes.should == { 'length' => 12 }
    end

    it 'sets any other attributes in the hash to #other_attributes for a collection' do
      Foo.root_node_name = :data
      users = Foo.load('data' => [{:id => 123}], 'length' => 12)
      users.other_attributes.should == { 'length' => 12 }
    end

    it 'sets any other attributes in the hash to #other_attributes for an instantiated object' do
      Foo.root_node_name = :data
      user = Foo.new
      user.load('data' => { :id => 123 }, 'length' => 12)
      user.other_attributes.should == { 'length' => 12 }
    end

    it 'supports multiple root node names with a single resource' do
      Foo.root_node_name = [:data, :datum]
      user = Foo.new
      user.load('data' => { :id => 123 })
      user.id.should == 123
    end

    it 'supports multiple root node names with a collection' do
      Foo.root_node_name = [:data, :datum]
      users = Foo.load('data' => [{ :id => 123 }, { :id => 124 }])
      users.map(&:id).should == [123, 124]
    end
  end

  describe '#load' do
    before :each do 
      @now = DateTime.now
      @now_as_string = @now.to_s
      @post = Bar.new
      @post.title = "Lorem Ipsum"
      @comments = []
      4.times do
        comment = Buzz.new
        comment.body = "Lorem Ipsum"
        @comments << comment
      end
    end

    it 'loads attributes' do
      user = Foo.new
      user.load({ :name => 'Bob' })
      user.name.should == 'Bob'
    end

    it 'overwrites existing attributes' do
      user = Foo.new
      user.name = 'Andrew'
      user.load({ :name => 'Bob' })
      user.name.should == 'Bob'
    end

    it 'loads objects based on their type in the attributes method' do
      user = Foo.new
      user.load({
        :id => "123",
        :name => "Andrew",
        :created_at => @now_as_string
      })

      user.id.should == 123
      user.name.should == 'Andrew'
      user.created_at.to_s.should == @now_as_string
    end

    it 'loads associations' do
      user = Foo.new
      user.load({
        :post => {
          :title => 'Lorem Ipsum'
        }
      })

      user.post.title.should == 'Lorem Ipsum'
    end

    it 'loads association arrays' do
      user = Foo.new
      user.load({
        :comments => [
          { :body => 'Lorem Ipsum' },
          { :body => 'Lorem Ipsum' }
        ]
      })

      user.comments.each do |comment|
        comment.body.should == 'Lorem Ipsum'
      end
    end

    it 'loads arrays' do
      user = Foo.new
      user.load({
        :comments_text => [
          'Lorem Ipsum',
          'Lorem Ipsum'
        ]
      })

      user.comments_text.each do |comment|
        comment.should == 'Lorem Ipsum'
      end
    end

    it 'skips unknown attributes' do
      user = Foo.new
      user.load({
        :fizz => '',
        :name => 'Andrew'
      })

      user.name.should == 'Andrew'
    end
  end
end
