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
    config.i18n.enforce_available_locales = false
    config.i18n.default_locale = :en

    # Ensures precompiling is faster by not loading the application
    config.assets.initialize_on_precompile = false

    config.destroyable_states = ['pending','available']
    config.destroyed_state = 'destroyed'
    config.stampable_state = 'created'
    config.qcable_state = 'pending'
    config.qcing_state = 'qc_in_progress'
    config.qced_state = 'available'
    config.used_state = 'exhausted'

    config.stamp_range = (10..500)
    config.stamp_step = 10

    config.tracked_purposes = [
      'Tag Plate',
      'Reporter Plate',
      'QA Plate',
      'Tag PCR',
      'Tag PCR-XP',
      'Tag Stock-MX',
      'Tag MX',
      'Pre Stamped Tag Plate'
    ]

    config.purpose_handlers = {
      'Tag Plate' => {
        :with    => 'plate_conversion',
        :as      => 'target',
        :sibling => 'Reporter Plate'
      },
      'Pre Stamped Tag Plate' => {
        :with    => 'plate_conversion',
        :as      => 'target',
        :sibling => 'Reporter Plate'
      },
      'Reporter Plate' => {
        :with    => 'plate_conversion',
        :as      => 'source',
        :sibling => 'Tag Plate'
      },
      'QA Plate' => {
        :with    => 'qa_plate_conversion',
        :as      => 'source',
        :sibling => 'Tag Plate'
      },
      'Tag PCR' => {
      },
      'Tag PCR-XP' => {
        :with => 'tube_creation'
      },
      'Tag Stock-MX' => {
        :with => 'tube_transfer',
        :printer => 'tube'
      },
      'Tag MX' => {
        :with => 'completed',
        :printer => 'tube'
      }
    }

    config.default_purpose_handler = {
      :with    => 'plate_conversion_to_default',
      :name    => 'QA Plate',
      :as      => 'target'
    }

    # If no study or project is specified, the config will fall back
    # to the first study/project
    config.study_uuid = nil
    config.project_uuid = nil

    config.request_options = {
      "read_length" => 25,
      "fragment_size_required" => {
        "from" => 0,
        "to"   => 100
      },
      "library_type" => "QA1"
    }
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

