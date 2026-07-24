# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test '#search for existing user' do
    mock_user = MockApiV2.mock_user(swipecard: '123456789')

    post :search, params: { user_swipecard: '123456789' }

    assert_response :success
    assert_equal Presenter::User, assigns['user'].class
    assert_equal assigns['user'].user, mock_user
  end

  test '#search for missing user' do
    Sequencescape::Api::V2::User.expects(:find!).with(user_code: '123456789').raises(JsonApiClient::Errors::NotFound, 'Resource not found')

    post :search, params: {  user_swipecard: '123456789' }

    assert_response :not_found
  end
end
