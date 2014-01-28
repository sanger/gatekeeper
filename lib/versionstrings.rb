begin
  require './lib/deployed_version'
rescue LoadError
  module Deployed
    VERSION_ID = 'LOCAL'
    VERSION_STRING = "#{Gatekeeper.config.app_name} LOCAL [#{ENV['RACK_ENV']}]"
  end
end
