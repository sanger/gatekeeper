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
    attr_accessor :app_name

    def initialize
      @version = VERSION
    end
  end

end

