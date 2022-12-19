# frozen_string_literal: true

require 'test_helper'
require 'mock_api'

class LotsQcDecisionsControllerTest < ActionDispatch::IntegrationTest
  include MockApi

  setup do
    mock_api
    api.mock_user('abcdef', '11111111-2222-3333-4444-555555555555')
  end

  test 'new' do
    get :new, params: { lot_id: '11111111-2222-3333-4444-555555555556' }
    assert_response :success
    assert_equal '11111111-2222-3333-4444-555555555556', assigns['lot_presenter'].uuid
  end

  test 'create' do
    api.qc_decision.expect_create_with(
      received: {
        user: '11111111-2222-3333-4444-555555555555',
        lot: '11111111-2222-3333-4444-555555555556',
        decisions: [
          { 'qcable' => '11111111-2222-3333-4444-100000000001', 'decision' => 'pass' },
          # {'qcable'=>'11111111-2222-3333-4444-100000000002', 'decision' => 'pass'},
          { 'qcable' => '11111111-2222-3333-4444-100000000003', 'decision' => 'release' },
          { 'qcable' => '11111111-2222-3333-4444-100000000004', 'decision' => 'release' },
          { 'qcable' => '11111111-2222-3333-4444-100000000005', 'decision' => 'release' },
          { 'qcable' => '11111111-2222-3333-4444-100000000006', 'decision' => 'release' },
          { 'qcable' => '11111111-2222-3333-4444-100000000007', 'decision' => 'release' },
          { 'qcable' => '11111111-2222-3333-4444-100000000008', 'decision' => 'release' },
          { 'qcable' => '11111111-2222-3333-4444-100000000009', 'decision' => 'release' },
          { 'qcable' => '11111111-2222-3333-4444-100000000010', 'decision' => 'release' }
        ]
      },
      returns: '11111111-2222-3333-9999-330000000008'
    )

    post :create, params: {
         lot_id: '11111111-2222-3333-4444-555555555556',
         user_swipecard: 'abcdef',
         decisions: {
           '11111111-2222-3333-4444-100000000001' => 'pass',
           '11111111-2222-3333-4444-100000000002' => '',
           '11111111-2222-3333-4444-100000000003' => 'release',
           '11111111-2222-3333-4444-100000000004' => 'release',
           '11111111-2222-3333-4444-100000000005' => 'release',
           '11111111-2222-3333-4444-100000000006' => 'release',
           '11111111-2222-3333-4444-100000000007' => 'release',
           '11111111-2222-3333-4444-100000000008' => 'release',
           '11111111-2222-3333-4444-100000000009' => 'release',
           '11111111-2222-3333-4444-100000000010' => 'release'
         }
    }

    assert_redirected_to controller: :lots, action: :show, id: '11111111-2222-3333-4444-555555555556'
    assert_equal 'Qc decision has been updated.', flash[:success]
  end

  test 'handle record invalid exceptions cleanly' do
    resource = mock('resource')
    errors = mock('errors')
    errors.stubs(:messages).returns(user: ["doesn't have permission"], second: ['bit is invalid'])
    resource.stubs(:errors).returns(errors)

    api.qc_decision.stubs(:create!).with(
      user: '11111111-2222-3333-4444-555555555555',
      lot: '11111111-2222-3333-4444-555555555556',
      decisions: [
        { 'qcable' => '11111111-2222-3333-4444-100000000001', 'decision' => 'pass' }
      ]
    ).raises(Sequencescape::Api::ResourceInvalid.new(resource))

    post :create, params: {
         lot_id: '11111111-2222-3333-4444-555555555556',
         user_swipecard: 'abcdef',
         decisions: {
           '11111111-2222-3333-4444-100000000001' => 'pass'
         }
    }

    assert_redirected_to '/lots/11111111-2222-3333-4444-555555555556/qc_decisions/new'
    assert_equal "A decision was not made. User doesn't have permission; Second bit is invalid.", flash[:danger]
  end
end
