require 'test_helper'
require 'mock_api'

class BatchesQcDecisionsControllerTest < ActionController::TestCase

  include MockApi

  setup do
    mock_api
    api.mock_user('abcdef','11111111-2222-3333-4444-555555555555')
  end

  test "new" do
    api.search.with_uuid('d8986b60-b104-11e3-a4d5-44fb42fffecc').
    expects(:all).
    with(Sequencescape::Lot, :batch_id => '12345').
    returns([api.lot.with_uuid('11111111-2222-3333-4444-555555555556')])

    get :new, {:batch_id => '12345' }
    assert_response :success
    assert_equal '11111111-2222-3333-4444-555555555556', assigns['lots_presenter'].lots.first.uuid
    assert_equal '12345', assigns['lots_presenter'].batch_id
  end

  test "create just the pending decisions for the lot" do

    lot = api.lot.with_uuid('11111111-2222-3333-4444-555555555556')

    # We mock here, as this is out interface with the controller.
    lot.expects(:pending_qcable_uuids).returns(['11111111-2222-3333-4444-100000000008','11111111-2222-3333-4444-100000000009'])

    api.search.with_uuid('d8986b60-b104-11e3-a4d5-44fb42fffecc').
    expects(:all).
    with(Sequencescape::Lot, :batch_id => '12345').
    returns([lot])

    api.qc_decision.expect_create_with(
      :received => {
        :user =>    '11111111-2222-3333-4444-555555555555',
        :lot =>     '11111111-2222-3333-4444-555555555556',
        :decisions => [
          {'qcable'=>'11111111-2222-3333-4444-100000000008', 'decision' => 'release'}, # Was pending
          {'qcable'=>'11111111-2222-3333-4444-100000000009', 'decision' => 'release'}  # Was pending
        ]
      },
      :returns => '11111111-2222-3333-9999-330000000008'
      )

    @request.headers["Accept"] = "application/json"

    post :create, {
      :batch_id  => '12345',
      :lot_id    => '11111111-2222-3333-4444-555555555556',
      :user_swipecard => 'abcdef',
      :decision => 'release'
    }
  end

  test "validate user before performing change" do

    post :create, {
      :batch_id  => '12345',
      :lot_id    => '11111111-2222-3333-4444-555555555556',
      :user_swipecard => 'abcdeg',
      :decisions => {
        '11111111-2222-3333-4444-100000000001' => 'passed'
      }
    }

    assert_equal true, flash[:danger].include?("User could not be found")
  end

end
