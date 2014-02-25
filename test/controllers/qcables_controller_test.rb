require 'test_helper'
require 'mock_api'

class QcablesControllerTest < ActionController::TestCase

  include MockApi

  setup do
    mock_api
  end

  test "create" do

    api.mock_user('abcdef','11111111-2222-3333-4444-555555555555')

    api.qcable_creator.expect_create_with(
      :received => {
        :user => '11111111-2222-3333-4444-555555555555',
        :lot => '11111111-2222-3333-4444-555555555556',
        :count => 10
        },
      :returns  => '11111111-2222-3333-4444-555555555558'
      )

    target_printer = api.barcode_printer.find('baac0dea-0000-0000-0000-000000000000')

    (1..10).map {|i| Sanger::Barcode::Printing::Label.expects(:new).with(:prefix=>'DN',:number=>i.to_s,:study=>'123456789:Example Tag Layout') }

    mock_printer = mock('printer')
    mock_printer.expects(:print!).returns(true)
    BarcodeSheet.expects(:new).returns(mock_printer)

    post :create, {
      :user_swipecard => 'abcdef',
      :lot_id => '11111111-2222-3333-4444-555555555556',
      :plate_number => 10,
      :barcode_printer => 'baac0dea-0000-0000-0000-000000000000'
    }

    assert_redirected_to :controller=>:lots, :action => :show, :id=> '11111111-2222-3333-4444-555555555556'
    assert_equal '10 plates have been created.', flash[:success]
  end


  test "create with no user" do

    api.mock_user('123456789','11111111-2222-3333-4444-555555555555')
    post :create, {
      :lot_id => '11111111-2222-3333-4444-555555555556',
      :plate_number => 10
    }
    assert_redirected_to :root
    assert_equal 'User swipecard must be provided.', flash[:danger]
  end

  test "#create with fake user" do

    api.mock_user('123456789','11111111-2222-3333-4444-555555555555')
    post :create, {
      :user_swipecard => 'fake_user',
      :lot_id => '11111111-2222-3333-4444-555555555556',
      :plate_number => 10
    }
    assert_redirected_to :root
    assert_equal 'User could not be found, is your swipecard registered?', flash[:danger]
  end

end
