require 'test_helper'

class RobotsControllerTest < ActionController::TestCase

  include MockApi

  setup do
    mock_api
    @robot = api.robot.with_uuid('40b07000-0000-0000-0000-000000000000')
  end

  test "#search" do
    @request.headers["Accept"] = "application/json"

    api.search.with_uuid('689a48a0-9d46-11e3-8fed-44fb42fffedd').
    expects(:first).
    with(:barcode => '488000000178').
    returns(@robot)

    post :search, {:robot_barcode => '488000000178'}
    assert_equal Presenter::Robot, assigns['robot'].class
    assert_equal @robot, assigns['robot'].robot
  end

  test "#search for missing" do
    @request.headers["Accept"] = "application/json"

    api.search.with_uuid('689a48a0-9d46-11e3-8fed-44fb42fffedd').
    expects(:first).
    with(:barcode => '1234567890123').
    raises(Sequencescape::Api::ResourceNotFound,'There is an issue with the API connection to Sequencescape (["no resources found with that search criteria"])')

    post :search, {:robot_barcode => '1234567890123'}
    assert_response 404
  end


end
