# frozen_string_literal: true

require 'test_helper'

class HealthControllerTest < ActionController::TestCase
  test 'returns OK when Sequencescape is available' do
    test_conn = Faraday.new do |builder|
      builder.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get('/health') { |_env| [200, {}, 'OK'] }
      end
    end
    @controller.stubs(:sequencescape_conn).returns(test_conn)

    get :show
    assert_response :success
    assert_equal 'OK', @response.body
  end

  test 'returns Gateway Timeout when Sequencescape connection times out' do
    test_conn = Faraday.new do |builder|
      builder.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get('/health') { |_env| raise Faraday::TimeoutError }
      end
    end
    @controller.stubs(:sequencescape_conn).returns(test_conn)

    get :show
    assert_response :gateway_timeout
    assert_equal 'Connection to Sequencescape timed out', @response.body
  end

  test 'returns Bad Gateway when Sequencescape is unavailable' do
    test_conn = Faraday.new do |builder|
      builder.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get('/health') { |_env| raise Faraday::ServerError, 'Internal server error' }
      end
    end
    @controller.stubs(:sequencescape_conn).returns(test_conn)

    get :show
    assert_response :bad_gateway
    assert_equal 'Sequencescape is unavailable', @response.body
  end
end
