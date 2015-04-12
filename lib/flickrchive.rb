require 'flickraw'
require 'flickrchive/config'
require 'flickrchive/prepare'
require 'flickrchive/execute'
require 'flickrchive/status'
require 'logger'

module Flickrchive
  class <<self
    attr_accessor :logger
  end
end
