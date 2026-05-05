# frozen_string_literal: true

require 'test_helper'
require 'mock_api'

class BatchesQcDecisionsControllerTest < ActionController::TestCase
  include MockApi

  setup do
    mock_api
    api.mock_user('abcdef', '11111111-2222-3333-4444-555555555555')
  end

  test 'new' do
    lot = Sequencescape::Api::V2::Lot.new(
      uuid: '11111111-2222-3333-4444-555555555556',
      lot_number: '123456789',
      lot_type_name: 'IDT Tags',
      template_name: 'Example Tag Layout',
      received_at: '2013-02-01'
    )

    # We mock here, as this is out interface with the controller.
    lot.expects(:pending_qcable_uuids).returns(%w[11111111-2222-3333-4444-100000000008 11111111-2222-3333-4444-100000000009])

    Sequencescape::Api::V2::Lot.expects(:where).with(batch_id: '12345').returns(
      mock('v2_lot_scope').tap { |s| s.stubs(:all).returns([lot]) }
    )

    get :new, params: { batch_id: '12345' }
    assert_response :success
    assert_equal '11111111-2222-3333-4444-555555555556', assigns['lots_presenter'].lots.first.uuid
    assert_equal '12345', assigns['lots_presenter'].batch_id
  end

  test 'create just the pending decisions for the lot' do
    lot = Sequencescape::Api::V2::Lot.new(
      uuid: '11111111-2222-3333-4444-555555555556',
      lot_number: '123456789',
      lot_type_name: 'IDT Tags',
      template_name: 'Example Tag Layout',
      received_at: '2013-02-01'
    )

    # We mock here, as this is out interface with the controller.
    lot.expects(:pending_qcable_uuids).returns(%w[11111111-2222-3333-4444-100000000008 11111111-2222-3333-4444-100000000009])

    Sequencescape::Api::V2::Lot.expects(:find).with('11111111-2222-3333-4444-555555555556').returns(lot)

    api.qc_decision.expect_create_with(
      received: {
        user: '11111111-2222-3333-4444-555555555555',
        lot: '11111111-2222-3333-4444-555555555556',
        decisions: [
          { 'qcable' => '11111111-2222-3333-4444-100000000008', 'decision' => 'release' }, # Was pending
          { 'qcable' => '11111111-2222-3333-4444-100000000009', 'decision' => 'release' }  # Was pending
        ]
      },
      returns: '11111111-2222-3333-9999-330000000008'
    )

    @request.headers['Accept'] = 'application/json'

    post :create, params: {
         batch_id: '12345',
         lot_id: '11111111-2222-3333-4444-555555555556',
         user_swipecard: 'abcdef',
         decision: 'release'
    }
  end

  test 'validate user before performing change' do
    post :create, params: {
         batch_id: '12345',
         lot_id: '11111111-2222-3333-4444-555555555556',
         user_swipecard: 'abcdeg',
         decisions: {
           '11111111-2222-3333-4444-100000000001' => 'passed'
         }
    }

    assert_equal true, flash[:danger].include?('User could not be found')
  end
end
