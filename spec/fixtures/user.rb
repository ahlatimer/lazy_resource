class User
  include LazyResource::Resource

  attribute :id,   Fixnum
  attribute :name, String
  attribute :created_at, DateTime
  attribute :post, Post
  attribute :comments, [Comment]
end
