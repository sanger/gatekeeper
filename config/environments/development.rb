require 'pry'
Gatekeeper::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Set up the API connection options
  config.api_connection_options               = ActiveSupport::OrderedOptions.new
  config.api_connection_options.namespace     = 'Gatekeeper'
  config.api_connection_options.url           = 'http://localhost:3000/api/1/'
  config.api_connection_options.authorisation = 'development'

  config.support_mail = 'example@example.com'

  # We can either pass in an array of printer names, or accept all printers with :all
  # Note that this list is built as part of rake:config:generate
  config.approved_printers = :all

  # Set up approved templates List built on rake:config:generate
  # Split by class, set up with name
  config.approved_templates = ActiveSupport::OrderedOptions.new
  config.approved_templates.plate_template      = :all
  config.approved_templates.tag_layout_template = :all
end
