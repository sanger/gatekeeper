

# require 'sinatra'
# require 'sinatra/partial'

# require './lib/gatekeeper'
# require './app/gatekeeper'
# require './config/config'
# require './lib/versionstrings'

# Gatekeeper.config.root_dir = File.dirname(__FILE__)

# run Gatekeeper::Application
# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application
