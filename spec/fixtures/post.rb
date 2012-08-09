class Post
  include LazyResource::Resource

  attribute :id, Fixnum
  attribute :title, String
end
