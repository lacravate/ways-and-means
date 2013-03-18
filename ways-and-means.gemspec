# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'ways-and-means/version'

Gem::Specification.new do |s|
  s.name          = "ways-and-means"
  s.version       = WaysAndMeans::VERSION
  s.authors       = ["lacravate"]
  s.email         = ["lacravate@lacravate.fr"]
  s.homepage      = "https://github.com/lacravate/ways-and-means"
  s.summary       = "Sinatra routes and Sinatra settings from configuration data"
  s.description   = "Sinatra routes and Sinatra settings through configuration data, hash or yaml file"

  s.files         = `git ls-files app lib`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.rubyforge_project = '[none]'

  s.add_dependency "sinatra"
  s.add_dependency "pathstring"

  s.add_development_dependency "rspec"
  s.add_development_dependency 'rack-test'
end
