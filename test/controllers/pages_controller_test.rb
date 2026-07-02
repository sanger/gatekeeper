# frozen_string_literal: true

require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test '#index' do
    get :index
    assert_response :success
    assert_select 'title', 'Gatekeeper'
  end
end
