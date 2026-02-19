# frozen_string_literal: true

require 'test_helper'

class HealthControllerTest < ActionDispatch::IntegrationTest
  test 'should get health' do
    get health_url
    assert_response :success
    assert_equal 'OK', @response.body.strip
  end
end
