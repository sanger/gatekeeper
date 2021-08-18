# frozen_string_literal: true

require 'test_helper'
require 'mock_api'

class BarcodeLabelsControllerTest < ActionController::TestCase
  include MockApi

  setup do
    mock_api
  end

  ## CREATE
  test 'create' do
    api.mock_user('abcdef', '11111111-2222-3333-4444-555555555555')

    post :create, params: {}
    assert_nil flash[:danger]
    # assert_equal 'Created lot 123456789', flash[:success]
    # assert_redirected_to action: :show, id: '11111111-2222-3333-4444-555555555556'
  end
end
