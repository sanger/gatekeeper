#\ -s puma

require 'sinatra'
require './lib/gatekeeper'
require './app/gatekeeper'
require './config/config'
require './lib/versionstrings'

run Gatekeeper::Application
