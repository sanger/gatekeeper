# frozen_string_literal: true

# https://github.com/simplecov-ruby/simplecov#getting-started

require 'simplecov'
require 'simplecov_json_formatter'
require 'simplecov-lcov'
SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov::Formatter::LcovFormatter.config.single_report_path = 'coverage/lcov.info'
SimpleCov.formatters =
  SimpleCov::Formatter::MultiFormatter.new(
    [SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::JSONFormatter, SimpleCov::Formatter::LcovFormatter]
  )
SimpleCov.start :rails

ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/rails'
require 'mocha/minitest'
# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
require 'capybara/rails'
require 'capybara/minitest'
require 'capybara/minitest/spec'

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  # Make `assert_*` methods behave like Minitest assertions
  include Capybara::Minitest::Assertions

  # Reset sessions and driver between tests
  teardown do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

require 'selenium/webdriver'

# Uncomment for awesome colourful output
require 'minitest/pride'

begin
  require 'pry-rails'
rescue LoadError
  true
  # No pry. We're probably on the CI
end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--disable_gpu')
  options.add_argument('--window-size=1600,1600')
  options.add_argument('--no-sandbox')
  options.add_preference('profile.password_manager_leak_detection', false)

  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

Capybara.default_driver = :headless_chrome
Capybara.default_max_wait_time = 5

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end
