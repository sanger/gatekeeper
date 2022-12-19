# frozen_string_literal: true

require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test '#index' do
    Sequencescape::Api.expects(:new)
    get :index
    assert_response :success
    assert_select 'title', 'Gatekeeper'
  end
end
