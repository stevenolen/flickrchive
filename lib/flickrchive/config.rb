require 'flickrchive/prepare'
require 'flickrchive/execute'
require 'yaml'
require 'daybreak'

module Flickrchive
  class Config
    include Flickrchive::Prepare
    include Flickrchive::Execute
    attr_accessor :db_file, :directory, :log_level, :log_file, :username, :db, :sets, :excludes

    def initialize(config_file = nil)
      begin
        config = YAML.load_file(config_file || "#{ENV['HOME']}/.flickrchive.yml") 
        # do i need to keep my flickr api key secret?
        FlickRaw.api_key = config['api_key']
        FlickRaw.shared_secret = config['shared_secret']
        if config['access_token'].nil? || config['access_secret'].nil?
          config['access_token'], config['access_secret'] = auth
          File.open("#{ENV['HOME']}/.flickrchive.yml", 'w') { |f| YAML.dump(config, f) }
        end
        flickr.access_token = config['access_token']
        flickr.access_secret = config['access_secret']
        self.db_file = config['db_file']
        self.directory = File.join(config['directory'], "") # ensure dir ends in trailing slash
        self.excludes = config['excludes']
        init_logger(config)
        self.username = try_login
        self.db = Daybreak::DB.new self.db_file
        Flickrchive.logger.debug("Flickrchive initialized as #{self.username}.")
        self
      rescue => e
          # config step inits logger, just put to STDOUT until we can be sure the logger exists
          puts e
          exit
      end
    end

    def init_logger(config)
      log_level = config['log_level'] || 'debug'
      log_file = config['log_file'] || STDOUT
      Flickrchive.logger = Logger.new(log_file)
      Flickrchive.logger.level = Logger.const_get(log_level.upcase)
    end

    def try_login
      login = flickr.test.login
      return login.username
    end

    def auth
      token = flickr.get_request_token
      auth_url = flickr.get_authorize_url(token['oauth_token'], :perms => 'delete')
      puts "Open this url in your process to complete the authication process : #{auth_url}"
      puts "Copy here the number given when you complete the process."
      verify = gets.strip
      begin
        flickr.get_access_token(token['oauth_token'], token['oauth_token_secret'], verify)
        login = flickr.test.login
        return flickr.access_token, flickr.access_secret
        #puts "You are now authenticated as #{login.username} with token #{flickr.access_token} and secret #{flickr.access_secret}"
      rescue FlickRaw::FailedResponse => e
        puts "Authentication failed : #{e.msg}"
      end
    end
  end
end