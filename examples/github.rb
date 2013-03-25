require 'lazy_resource'
require 'benchmark'

class SimpleLogger
  def info(message)
    puts message
  end
end

LazyResource.configure do |config|
  config.site = "https://api.github.com"
  config.logger = SimpleLogger.new
  config.debug = true
end

class User
  include LazyResource::Resource
end

class Repo
  include LazyResource::Resource

  attribute :id,          Fixnum
  attribute :pushed_at,   DateTime
  attribute :owner,       User
  attribute :clone_url,   String
  attribute :name,        String
  attribute :description, String
end

class User
  include LazyResource::Resource

  self.primary_key_name = 'login'

  attribute :id,          Fixnum
  attribute :login,       String
  attribute :name,        String
  attribute :bio,         String
  attribute :company,     String
  attribute :number_of_public_repos, Fixnum, :from => 'public_repos'
  attribute :repos,       [Repo]
end

dhh = User.find('dhh')
dhh.repos.each do |repo|
  puts "#{dhh.name} pushed to #{repo.name} on #{repo.pushed_at.strftime("%D")}"
end

puts "Fetching 10 users serially..."
Benchmark.bm do |x|
  x.report do
    names = []
    10.times do |i|
      u = User.find(i + 1)
      names << u.name
    end
    
    puts names
  end
end

puts "\nFetching 10 users in parallel..."
Benchmark.bm do |x|
  x.report do
    users = []
    10.times do |i|
      users << User.find(i + 1)
    end
    puts users.map { |user| user.name }
  end
end
