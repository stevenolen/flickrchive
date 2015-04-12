lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
#require 'ohmage/version'

Gem::Specification.new do |spec|
  spec.add_dependency 'flickraw', '~> 0.9', '>= 0.9.8'
  spec.add_dependency 'ruby-filemagic', '~> 0.6', '>= 0.6.3'
  spec.add_dependency 'daybreak', '~> 0.3', '>= 0.3.0'
  spec.add_dependency 'thor', '~> 0.19', '>= 0.19.1'
  spec.authors = ['Steve Nolen']
  spec.description = 'A photo archiver to flickr in ruby'
  spec.email = %w(technolengy@gmail.com)
  spec.files = %w(LICENSE flickrchive.gemspec bin/flickrchive) + Dir['lib/**/*.rb']
  spec.homepage = 'https://github.com/stevenolen/flickrchive'
  spec.licenses = %w(Apache 2)
  spec.name = 'flickrchive'
  spec.executables = 'flickrchive'
  spec.require_paths = %w(lib)
  spec.required_ruby_version = '>= 1.9.3'
  spec.required_rubygems_version = '>= 1.3.5'
  spec.summary = spec.description
  spec.version = '0.1.6'
end
