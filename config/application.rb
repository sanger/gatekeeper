require File.expand_path('../boot', __FILE__)

# We don't want ActiveRecord
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"
require './lib/gatekeeper/version'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Gatekeeper
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.name = 'Gatekeeper'

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Ensures precompiling is faster by not loading the application
    config.assets.initialize_on_precompile = false

    config.destroyable_states = ['pending','available']
    config.destroyed_state = 'destroyed'
  end

  begin
    require './lib/deployed_version'
  rescue LoadError
      module Deployed
        VERSION_ID = 'LOCAL'
        VERSION_STRING = "#{Gatekeeper::Application.config.name} LOCAL [#{ENV['RACK_ENV']}]"
      end
  end


  def self.application_string
    Deployed::VERSION_STRING
  end


end

