# LazyResource

[ActiveResource](http://github.com/rails/activeresource) with its feet
up. The block less, do more consumer of delicious APIs.

LazyResource is `ActiveRecord` made less blocking. Built on top of
[Typhoeus](https://github.com/typhoeus/typhoeus), it queues up your requests to make your
API consumer a whole lot quicker. Work smarter, not harder.

It also has a simple, readable, easy-to-use API, borrowing some of the
best parts of ActiveResource with a bit of ActiveRecord method-chaining
flair. Not only is it faster, it's better-looking, too.

Don't believe me? Check out some of the examples in the `examples` directory
to see for yourself.

## Installation

Add this line to your application's Gemfile:

    gem 'lazy_resource'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lazy_resource

## Usage

### Define a model:

    class User
      include LazyResource::Resource

      self.site = 'http://example.com'

      attribute :id, Integer
      attribute :first_name, String
      attribute :last_name, String
    end

### Then use it:

    me = User.find(1)                                                    # => GET /users/1
    bobs = User.where(:first_name => 'Bob')                              # => GET /users?first_name=Bob
    sam = User.find_by_first_name('Sam')                                 # => GET /users?first_name=Sam
    terry = User.new(:first_name => 'Terry', :last_name => 'Simpson')
    terry.save                                                           # => POST /users
    terry.last_name = 'Jackson'
    terry.save                                                           # => PUT /users/4
    terry.destroy                                                        # => DELETE /users/4

### What about associations?

    class Post
      include LazyResource::Resource

      self.site = 'http://example.com'

      attribute :id, Integer
      attribute :title, String
      attribute :body, String
      attribute :user, User
    end

    class User
      include LazyResource::Resource
      # Attributes that have a type in an array are has-many
      attribute :posts, [Post]
    end

    me = User.find(1)
    me.posts.all       # => GET /users/1/posts

### That's cool, but what if my end-point doesn't map with my association name?

    class Photo
      include LazyResource::Resource

      attribute :id, Integer
      attribute :urls, Hash
      attribute :photographer, User, :from => 'users'
    end

### I thought you said this was non-blocking?

It is. That original example above with me, the Bobs, Sam, and Terry? Those
first four requests would all get executed at the same time, when Terry
was saved. Pretty neat, eh?

### That's great, but could you show me some examples that are a bit more complex?

Sure thing! Take a look at the files in the `examples` directory, or
read through the specs.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Make sure you have some decent test coverage, and please don't bump up
the version number. If you want to maintain your own version, go for it,
but put it in a separate commit so I can ignore it when I merge the rest
of your stuff in.

## It's alpha, yo

I'm not using this in production anywhere (yet), so use at your own
risk. It's got a pretty comprehensive test suite, but I'm sure there
are at least a few bugs. If you find one, [report it](https://github.com/ahlatimer/lazy_resource/issues).

## Recognition

Thanks to:

* [Typhoeus](http://github.com/typhoeus/typhoeus) for the http request
  queuing code that forms the foundation of LazyResource.
* [ActiveResource](http://github.com/rails/activeresource) for the idea
  (and a bit of code).
* [Get Satisfaction](http://getsatisfaction.com) for putting food on my
  table.

## TODO

 * Clean up `LazyResource::Attributes#create_setter`
 * Add more specs for associations

