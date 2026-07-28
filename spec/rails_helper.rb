# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'capybara/rspec'
require 'rspec/rails'
require 'selenium/webdriver'
require_relative 'spec_helper'

# For running Selenium at a lower speed
# Very useful when recording test runs
# https://stackoverflow.com/a/46840590/2037928
if ENV['SLOW'].present?
  module ::Selenium::WebDriver::Remote
    class Bridge
      alias old_execute execute

      def execute(*)
        sleep(0.2)
        old_execute(*)
      end
    end
  end
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless') if ENV['HEADED'].blank?
  options.add_argument('--disable_gpu')
  options.add_argument('--window-size=1600,1600')
  options.add_argument('--no-sandbox')
  options.add_preference('profile.password_manager_leak_detection', false)

  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :headless_chrome
Capybara.default_max_wait_time = 5

RSpec.configure do |config|
  config.fixture_path = Rails.root.join('test/fixtures').to_s
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
