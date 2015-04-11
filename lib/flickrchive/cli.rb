require 'thor'
require 'flickrchive'

module Flickrchive
  class CLI < Thor
    class_option :config, :type => :string

    desc 'prep', 'initializes the db, recursively searching directory for photos'
    def prep
      f = Flickrchive::Config.new(options[:config])
      f.prepare
    end

    desc 'exec', 'attempts to upload photos in db to flickr'
    def exec
      f = Flickrchive::Config.new(options[:config])
      f.execute
    end
  end
end
