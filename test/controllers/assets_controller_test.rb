require 'test_helper'
require 'mock_api'

class AssetsControllerTest < ActionController::TestCase

  include MockApi

  setup do
    mock_api
  end

  test "destroy" do
    api.mock_user('123456789','11111111-2222-3333-4444-555555555555')

    asset = api.asset.with_uuid('11111111-2222-3333-4444-300000000010')
    asset.class_eval { include BarcodeExtensions; include Gatekeeper::Asset::StateExtensions; }
    api.search.with_uuid('e7d2fec0-956f-11e3-8255-44fb42fffecc').
      expects(:first).
      with(:barcode => '1220000010734').
      returns(asset)

    api.state_change.expect_create_with(
      :received =>{
        :user => '11111111-2222-3333-4444-555555555555',
        :target => '11111111-2222-3333-4444-300000000010',
        :target_state => 'destroyed',
        :reason => 'Plate Dropped'
        },
      :returns  => '55555555-6666-7777-8888-000000000003'
    )

    delete :destroy, {
      :user_swipecard => '123456789',
      :asset_barcode => '1220000010734',
      :reason => 'Plate Dropped'
    }

    assert_redirected_to :root
    assert_equal nil, flash[:danger]
    assert_equal 'DN10 has been destroyed!', flash[:success]
  end

  test "destroy with invalid barcode" do
    api.mock_user('123456789','11111111-2222-3333-4444-555555555555')

    api.search.with_uuid('e7d2fec0-956f-11e3-8255-44fb42fffecc').
      expects(:first).
      with(:barcode => '1220000010734').
      raises(Sequencescape::Api::ResourceNotFound,'There is an issue with the API connection to Sequencescape (["no resources found with that search criteria"])')

    delete :destroy, {
      :user_swipecard => '123456789',
      :asset_barcode => '1220000010734',
      :reason => 'Plate Dropped'
    }

    assert_redirected_to :root
    assert_equal 'Could not find an asset with the barcode 1220000010734.', flash[:danger]
  end

end
