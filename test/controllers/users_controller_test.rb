# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include MockApi

  setup do
    mock_api
    @user = api.user.with_uuid('11111111-2222-3333-4444-555555555555')
  end

  test '#search' do
    @request.headers['Accept'] = 'application/json'

    api.mock_user('123456789', '11111111-2222-3333-4444-555555555555')

    post :search, params: { user_swipecard: '123456789' }

    assert_response :success
    assert_equal Presenter::User, assigns['user'].class
    assert_equal @user, assigns['user'].user
  end

  test '#search for missing' do
    @request.headers['Accept'] = 'application/json'

    api.search.with_uuid('e7e52730-956f-11e3-8255-44fb42fffecc')
       .expects(:first)
       .with(swipecard_code: '123456789')
       .raises(Sequencescape::Api::ResourceNotFound, 'There is an issue with the API connection to Sequencescape (["no resources found with that search criteria"])')

    post :search, params: {  user_swipecard: '123456789' }

    assert_response 404
  end
end
