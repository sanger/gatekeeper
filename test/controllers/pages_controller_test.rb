require 'test_helper'

class PagesControllerTest < ActionController::TestCase

  test "#index" do
    Sequencescape::Api.expects(:new)
    get :index
    assert_response :success
    assert_select 'title', "Gatekeeper"
  end


end
