# frozen_string_literal: true

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

require 'mock_api_v2'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  include MockApiV2
end
