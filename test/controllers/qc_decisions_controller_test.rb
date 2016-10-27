require 'test_helper'
require 'mock_api'

class QcDecisionsControllerTest < ActionController::TestCase

  include MockApi

  setup do
    mock_api
    api.mock_user('abcdef','11111111-2222-3333-4444-555555555555')
  end

  test "search" do
    api.search.with_uuid('d8986b60-b104-11e3-a4d5-44fb42fffecc').
    expects(:all).
    with(Sequencescape::Lot, batch_id: '12345').
    returns([api.lot.with_uuid('11111111-2222-3333-4444-555555555556')])

    post :search, {batch_id: '12345'}
    assert_redirected_to '/lots/11111111-2222-3333-4444-555555555556/qc_decisions/new'
  end

  test "search not found" do
    api.search.with_uuid('d8986b60-b104-11e3-a4d5-44fb42fffecc').
    expects(:all).
    with(Sequencescape::Lot, batch_id: '999').
    raises(Sequencescape::Api::ResourceNotFound,'There is an issue with the API connection to Sequencescape (["no resources found with that search criteria"])')

    post :search, {batch_id: '999'}

    assert_redirected_to :root
    assert_equal "Could not find an appropriate lot for batch 999.", flash[:danger]
  end

end
