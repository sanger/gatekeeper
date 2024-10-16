# frozen_string_literal: true

require 'pry'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.secret_key_base = 'example_dev_environment_key'
  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist? # rubocop:todo Rails/FilePath
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Set up the API connection options
  config.api_connection_options               = ActiveSupport::OrderedOptions.new
  config.api_connection_options.namespace     = 'Gatekeeper'
  config.api_connection_options.url           = ENV.fetch('API_URL', 'http://localhost:3000/api/1/')
  config.api_connection_options.authorisation = ENV.fetch('API_KEY', 'development')

  # We can either pass in an array of printer names, or accept all printers with :all
  # Note that this list is built as part of rake:config:generate
  config.approved_printers = :all

  # Set up approved templates List built on rake:config:generate
  # Split by class, set up with name
  config.suggested_templates = ActiveSupport::OrderedOptions.new
  config.suggested_templates.plate_template      = :all
  config.suggested_templates.tag_layout_template = :all

  config.pmb_uri = ENV.fetch('PMB_URI', 'http://localhost:3002/v1/')
  config.sprint_uri = 'http://example_sprint.com/graphql'

  # FreshService URL
  config.fresh_sevice_new_ticket_url = 'https://example.freshservice.com'
end
