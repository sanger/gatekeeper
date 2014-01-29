require './lib/gatekeeper/version'

module Gatekeeper

  # Your code goes here...
  def self.application_string
    Deployed::VERSION_STRING
  end

  def self.configure
    yield config if block_given?
  end

  def self.config
    @config ||= Configuration.new
  end

  class Configuration
    attr_reader :version
    attr_writer :root_dir
    attr_accessor :app_name

    def initialize
      @version = VERSION
    end

    def root_dir
      @root_dir || ENV['PWD']
    end

  end

end

