require 'spec_helper'

class Item
  include LazyResource::UrlGeneration

  attr_accessor :attributes

  class << self
    def collection_name
      'items'
    end

    def site
      'http://example.com/'
    end

    def primary_key_name
      'id'
    end
  end

  def initialize
    @id = 1
    @attributes = {} 
  end
end

describe LazyResource::UrlGeneration do
  describe '#element_path' do
    it 'calls the class element_path' do
      item = Item.new
      Item.should_receive(:element_path).with(1, nil)
      item.element_path
    end
  end

  describe '#new_element_path' do
    it 'calls the class element_path' do
      item = Item.new
      Item.should_receive(:new_element_path)
      item.new_element_path
    end
  end

  describe '#collection_path' do
    it 'calls the class element_path' do
      item = Item.new
      Item.should_receive(:collection_path)
      item.collection_path
    end
  end

  describe '#element_url' do
    it 'builds a full URL for the element' do
      item = Item.new
      item.element_url.should == 'http://example.com/items/1'
    end
  end

  describe '#collection_url' do
    it 'builds a full URL for the collection' do
      item = Item.new
      item.collection_url.should == 'http://example.com/items'
    end
  end

  describe '#split_options' do
    it 'calls the class element_path' do
      item = Item.new
      Item.should_receive(:split_options).with({})
      item.split_options({})
    end
  end

  describe '.prefix' do
    it 'returns / if no options are passed' do
      Item.prefix({}).should == '/'
    end

    it 'generates nested routes' do
      Item.prefix({ :user_id => 1, :post_id => 2 }).should == '/users/1/posts/2/'
    end
  end

  describe '.element_path' do
    it 'generates a single resource\'s path' do
      Item.element_path(1).should == '/items/1'
    end

    it 'prepends any parent resources' do
      Item.element_path(1, { :comment_id => 1, :post_id => 2 }).should == '/comments/1/posts/2/items/1'
    end

    it 'splits the prefix options (parent resources) from the parameters' do
      Item.element_path(1, { :comment_id => 1, :name => 'Andrew' }).should == '/comments/1/items/1?name=Andrew'
    end

    it 'puts parent resources in the query params if passed in the query_options hash' do
      Item.element_path(1, {}, { :comment_id => 1 }).should == '/items/1?comment_id=1'
    end

    it 'uses the "from" parameter over the collection name if passed' do
      Item.element_path(1, {}, {}, 'comments').should == '/comments/1'
    end
  end

  describe '.new_element_path' do
    it 'generates a path for a new element' do
      Item.new_element_path.should == '/items/new'
    end

    it 'prepends any parent resources' do
      Item.new_element_path(:comment_id => 1, :post_id => 2).should == '/comments/1/posts/2/items/new'
    end

    it 'uses from over the collection name if passed' do
      Item.new_element_path({}, 'comments').should == '/comments/new'
    end
  end

  describe '.collection_path' do
    it 'generates a collection\'s path' do
      Item.collection_path.should == '/items'
    end

    it 'prepends any parent resources' do
      Item.collection_path(:comment_id => 1, :post_id => 2).should == '/comments/1/posts/2/items'
    end

    it 'splits the prefix options (parent resources) from the parameters' do
      Item.collection_path(:comment_id => 1, :name => 'Andrew').should == '/comments/1/items?name=Andrew'
    end

    it 'puts parent resources in the params if passed in the query_options hash' do
      Item.collection_path({}, { :comment_id => 1 }).should == '/items?comment_id=1'
    end

    it 'uses the "from" parameter over the collection name if passed' do
      Item.collection_path({}, {}, 'comments').should == '/comments'
    end
  end

  describe '.query_string' do
    it 'creates a query string' do
      Item.query_string({ :name => 'Andrew', :comment_id => 1, :query => 'this is a query' }).should == '?comment_id=1&name=Andrew&query=this+is+a+query'
    end
  end

  describe '.split_options' do
    it 'splits prefix options from query options' do
      prefix_options, query_options = Item.split_options(:name => 'Andrew', :comment_id => 1)
      prefix_options.should == { :comment_id => 1 }
      query_options.should == { :name => 'Andrew' }
    end

    it 'ignores _ids params' do
      prefix_options, query_options = Item.split_options(:name => 'Andrew', :comment_ids => '1,2')
      query_options.should == { :name => 'Andrew', :comment_ids => '1,2' }
    end
  end
end
