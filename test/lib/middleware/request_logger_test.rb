# frozen_string_literal: true

require 'test_helper'

class MiddlewareRequestLoggerTest < Minitest::Test
  def setup
    @env = Rack::MockRequest.env_for(
      '/samples/1234?foo=bar',
      'REQUEST_METHOD' => 'GET',
      'REMOTE_ADDR' => '172.12.345.10',
      'action_dispatch.request_id' => 'test-request-id',
      'action_dispatch.request.parameters' => {},
      'action_dispatch.request.formats' => [Mime[:html]]
    )
    @logs = { info: [], debug: [] }
    @environment_context = { host: 'www.example.com', version: '1.2.3' }

    # Stub Rails.logger methods
    @original_logger = Rails.logger
    logs = @logs
    Rails.logger = Logger.new(StringIO.new)
    Rails.logger.define_singleton_method(:info) { |msg| logs[:info] << msg }
    Rails.logger.define_singleton_method(:debug) { |msg| logs[:debug] << msg }

    # Stub Rack::Utils.clock_time
    @original_clock_time = Rack::Utils.method(:clock_time)
    stub_rack_utils_clock_time

    # Stub Time.zone.now
    @original_time_now = Time.zone.method(:now)
    stub_time_zone_now
  end

  def teardown
    Rails.logger = @original_logger
    Rack::Utils.define_singleton_method(:clock_time, @original_clock_time)
    Time.zone.define_singleton_method(:now, @original_time_now)
  end

  def stub_rack_utils_clock_time
    Rack::Utils.define_singleton_method(:clock_time) do
      @__clock_times ||= [1.0, 1.23]
      @__clock_times.shift
    end
  end

  def stub_time_zone_now
    Time.zone.define_singleton_method(:now) do
      Time.new(2026, 2, 12, 12, 10, 50, '+00:00')
    end
  end

  def run_logger_with_status(status_code, log_level = :info)
    # Reset clock times for each test
    Rack::Utils.instance_variable_set(:@__clock_times, [1.0, 1.23])
    app = ->(_env) { [status_code, { 'Content-Type' => 'text/html' }, ['Response Body']] }
    middleware = Middleware::RequestLogger.new(app, log_level: log_level, environment_context: @environment_context)
    middleware.call(@env)
    @logs[log_level]
  end

  def test_logs_request_with_200
    logs = run_logger_with_status(200)
    assert(logs.any? { |msg| msg.include?('"method":"GET"') })
    assert(logs.any? { |msg| msg.include?('"url":"/samples/1234?foo=bar"') })
    assert(logs.any? { |msg| msg.include?('"path":"/samples/1234"') })
    assert(logs.any? { |msg| msg.include?('"format":"html"') })
    assert(logs.any? { |msg| msg.include?('"status_code":200') })
    assert(logs.any? { |msg| msg.include?('"status_message":"OK"') })
    assert(logs.any? { |msg| msg.include?('"duration_ms":230') })
    assert(logs.any? { |msg| msg.include?('"client_ip":"172.12.345.10"') })
    assert(logs.any? { |msg| msg.include?('"request_id":"test-request-id"') })
    assert(logs.any? { |msg| msg.include?('"host":"www.example.com"') })
    assert(logs.any? { |msg| msg.include?('"version":"1.2.3"') })
    assert(logs.any? { |msg| msg.include?('"tags":["request","success"]') })
    assert(logs.any? { |msg| msg.include?('"@timestamp":"2026-02-12T12:10:50.000+00:00"') })
  end

  def test_logs_request_with_404
    logs = run_logger_with_status(404)
    assert(logs.any? { |msg| msg.include?('"status_code":404') })
    assert(logs.any? { |msg| msg.include?('"status_message":"Not Found"') })
    assert(logs.any? { |msg| msg.include?('"tags":["request","client_error"]') })
  end

  def test_logs_request_with_500
    logs = run_logger_with_status(500)
    assert(logs.any? { |msg| msg.include?('"status_code":500') })
    assert(logs.any? { |msg| msg.include?('"status_message":"Internal Server Error"') })
    assert(logs.any? { |msg| msg.include?('"tags":["request","server_error"]') })
  end

  def test_logs_request_with_unknown_status
    logs = run_logger_with_status(789)
    assert(logs.any? { |msg| msg.include?('"status_code":789') })
    assert(logs.any? { |msg| msg.include?('"status_message":"Unknown Status"') })
    assert(logs.any? { |msg| msg.include?('"tags":["request"]') })
  end

  def test_logs_request_with_debug_level
    logs = run_logger_with_status(200, :debug)
    assert(logs.any? { |msg| msg.include?('"status_code":200') })
    assert(logs.any? { |msg| msg.include?('"tags":["request","success"]') })
  end
end
