# frozen_string_literal: true

require 'test_helper'
require 'mock_api'

class QcDecisionsControllerTest < ActionController::TestCase
  include MockApi

  setup do
    mock_api
    api.mock_user('abcdef', '11111111-2222-3333-4444-555555555555')
  end

  test 'search' do
    mock_lot = Sequencescape::Api::V2::Lot.new(uuid: '11111111-2222-3333-4444-555555555556')
    Sequencescape::Api::V2::Lot.expects(:where).with(batch_id: '12345').returns(
      mock('v2_lot_scope').tap { |s| s.stubs(:all).returns([mock_lot]) }
    )

    post :search, params: { batch_id: '12345' }
    assert_redirected_to '/lots/11111111-2222-3333-4444-555555555556/qc_decisions/new'
  end

  test 'search not found' do
    Sequencescape::Api::V2::Lot.expects(:where).with(batch_id: '999').returns(
      mock('v2_lot_scope').tap { |s| s.stubs(:all).returns([]) }
    )

    post :search, params: { batch_id: '999' }

    assert_redirected_to :root
    assert_equal 'Could not find an appropriate lot for batch 999.', flash[:danger]
  end
end
