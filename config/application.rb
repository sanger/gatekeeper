# frozen_string_literal: true

require_relative 'boot'

# We don't want ActiveRecord
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Gatekeeper
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.name = 'Gatekeeper'

    config.load_defaults 7.0

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.enforce_available_locales = false
    config.i18n.default_locale = :en
    config.i18n.fallbacks = [I18n.default_locale]

    # Ensures precompiling is faster by not loading the application
    config.assets.initialize_on_precompile = true
    config.disable_animations = false

    config.destroyable_states = %w[pending available]
    config.destroyed_state = 'destroyed'
    config.stampable_state = 'created'
    config.qcable_state = 'pending'
    config.qcing_state = 'qc_in_progress'
    config.qced_state = 'available'
    config.used_state = 'exhausted'

    config.printer_type_options = {
      '1D Tube' => { label: :tube, template: 'sqsc_1dtube_label_template' },
      '96 Well Plate' => { label: :plate, template: 'sqsc_96plate_label_template_code39' },
      '384 Well Plate' => { label: :plate, template: 'plate_384_single' },
      '384 Well Plate Double' => { label: :plate_double, template: 'plate_384' }
    }
  end

  require './lib/deployed_version'

  def self.application_string
    Deployed::VERSION_STRING
  end

  def self.commit_information
    Deployed::VERSION_COMMIT
  end

  def self.repo_url
    Deployed::REPO_URL
  end

  def self.host_name
    Deployed::HOSTNAME
  end

  def self.release_name
    Deployed::RELEASE_NAME
  end
end
