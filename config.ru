#\ -s puma

require 'sinatra'
require 'sinatra/partial'

require './lib/gatekeeper'
require './app/gatekeeper'
require './config/config'
require './lib/versionstrings'

Gatekeeper.config.root_dir = File.dirname(__FILE__)

run Gatekeeper::Application
