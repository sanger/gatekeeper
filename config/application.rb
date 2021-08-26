# frozen_string_literal: true

require File.expand_path('../boot', __FILE__)

# We don't want ActiveRecord
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'
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
    config.i18n.fallbacks = [I18n.default_locale]

    # Ensures precompiling is faster by not loading the application
    config.assets.initialize_on_precompile = false
    config.disable_animations = false

    config.destroyable_states = %w[pending available]
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
      'Tag 2 Tube',
      'Tag PCR',
      'Tag PCR-XP',
      'Tag Stock-MX',
      'Tag MX',
      'Pre Stamped Tag Plate'
    ]

    # When configuring multiple_tag2_conversion
    # steps, the recieving plate (The target)
    # MUST be configured as sibling

    config.purpose_handlers = {
      'Tag 2 Tube' => {
        with: 'multiple_tag2_conversion',
        sibling2: 'Reporter Plate',
        as: 'secondary',
        sibling: 'Tag Plate'
      },
      'Tag Plate' => {
        with: 'plate_conversion',
        as: 'target',
        sibling: 'Reporter Plate'
      },
      'Pre Stamped Tag Plate' => {
        with: 'plate_conversion',
        as: 'target',
        sibling: 'Reporter Plate'
      },
      'Reporter Plate' => {
        with: 'plate_conversion',
        as: 'source',
        sibling: 'Tag Plate'
      },
      'QA Plate' => {
        with: 'qa_plate_conversion',
        as: 'source',
        sibling: 'Tag Plate'
      },
      'Tag PCR' => {
      },
      'Tag PCR-XP' => {
        with: 'tube_creation'
      },
      'Tag Stock-MX' => {
        with: 'tube_transfer',
        printer: 'tube'
      },
      'Tag MX' => {
        with: 'completed',
        printer: 'tube'
      }
    }

    config.default_purpose_handler = {
      with: 'plate_conversion_to_default',
      child_name: 'QA Plate',
      as: 'target'
    }

    # If no study or project is specified, the config will fall back
    # to the first study/project
    config.study_uuid = nil
    config.project_uuid = nil

    config.request_options = {
      'read_length' => 11,
      'fragment_size_required' => {
        'from' => 1,
        'to' => 100
      },
      'library_type' => 'QA1'
    }

    config.printer_type_options = {
      '1D Tube' => { label: :tube, template: 'sqsc_1dtube_label_template' },
      '96 Well Plate' => { label: :plate, template: 'sqsc_96plate_label_template_code39' },
      '384 Well Plate' => { label: :plate, template: 'sqsc_384plate_label_template' },
      '384 Well Plate Double' => { label: :plate_double, template: 'plate_6mm_double_code39' }
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
