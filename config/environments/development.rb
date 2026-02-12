# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

require 'pry'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.secret_key_base = 'example_dev_environment_key'
  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

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

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  config.i18n.raise_on_missing_translations = false

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true

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
  config.api_connection_options.url_v2 = ENV.fetch('API_URL', 'http://localhost:3000/api/v2/')
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

  # Certain UI elements are believed to be unused, so we've disabled them.
  # This is a feature flag, to enable them again if needed.
  config.disable_unused_ui = true
end
