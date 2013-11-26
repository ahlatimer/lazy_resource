# -*- encoding: utf-8 -*-
require File.expand_path('../lib/lazy_resource/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andrew Latimer"]
  gem.email         = ["andrew@elpasoera.com"]
  gem.description   = %q{ActiveResource with its feet up. The write less, do more consumer of delicious APIs.}
  gem.summary       = %q{ActiveResource with its feet up. The write less, do more consumer of delicious APIs.}
  gem.homepage      = "http://github.com/ahlatimer/lazy_resource"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "lazy_resource"
  gem.require_paths = ["lib"]
  gem.version       = LazyResource::VERSION

  gem.add_dependency 'activemodel', '~> 3.1'
  gem.add_dependency 'activesupport', '~> 3.1'
  gem.add_dependency 'json', '>= 1.5.2'
  gem.add_dependency 'typhoeus', '0.6.6'
end
