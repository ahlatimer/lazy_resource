class Comment
  include LazyResource::Resource

  attribute :id, Fixnum
  attribute :body, String
end
