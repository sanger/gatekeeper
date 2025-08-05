# frozen_string_literal: true

require 'test_helper'
require 'mock_api'

class QcablesControllerTest < ActionController::TestCase
  include MockApi

  setup do
    mock_api
  end

  test 'create' do
    api.mock_user('abcdef', '11111111-2222-3333-4444-555555555555')

    api.qcable_creator.expect_create_with(
      received: {
        user: '11111111-2222-3333-4444-555555555555',
        lot: '11111111-2222-3333-4444-555555555556',
        count: 10
      },
      returns: '11111111-2222-3333-4444-555555555558'
    )

    api.barcode_printer.find('baac0dea-0000-0000-0000-000000000000')

    (1..10).map do |i|
      human_readable = SBCF::SangerBarcode.new(prefix: 'DN', number: i).human_barcode
      BarcodeSheet::Label.expects(:new).with(prefix: 'DN', number: i.to_s, barcode: human_readable, lot: '123456789', template: 'Example Tag Layout')
    end

    mock_barcode_sheet = mock('printer')
    mock_barcode_sheet.expects(:print!).returns(true)
    BarcodeSheet.expects(:new).returns(mock_barcode_sheet)

    post :create, params: {
         user_swipecard: 'abcdef',
         lot_id: '11111111-2222-3333-4444-555555555556',
         plate_number: 10,
         barcode_printer: 'baac0dea-0000-0000-0000-000000000000'
    }
    assert_redirected_to controller: :lots, action: :show, id: '11111111-2222-3333-4444-555555555556'
    assert_equal '10 Tag Plates have been created.', flash[:success]
  end

  test 'create when BarcodeSheet.print! errors' do
    api.mock_user('abcdef', '11111111-2222-3333-4444-555555555555')

    api.qcable_creator.expect_create_with(
      received: {
        user: '11111111-2222-3333-4444-555555555555',
        lot: '11111111-2222-3333-4444-555555555556',
        count: 10
      },
      returns: '11111111-2222-3333-4444-555555555558'
    )

    api.barcode_printer.find('baac0dea-0000-0000-0000-000000000000')

    (1..10).map do |i|
      human_readable = SBCF::SangerBarcode.new(prefix: 'DN', number: i).human_barcode
      BarcodeSheet::Label.expects(:new).with(prefix: 'DN', number: i.to_s, barcode: human_readable, lot: '123456789', template: 'Example Tag Layout')
    end

    mock_barcode_sheet = mock('barcode_sheet')
    mock_barcode_sheet.expects(:print!).raises(BarcodeSheet::PrintError, 'There was an issue with printing')

    BarcodeSheet.expects(:new).returns(mock_barcode_sheet)

    post :create, params: {
         user_swipecard: 'abcdef',
         lot_id: '11111111-2222-3333-4444-555555555556',
         plate_number: 10,
         barcode_printer: 'baac0dea-0000-0000-0000-000000000000'
    }
    assert_redirected_to controller: :lots, action: :show, id: '11111111-2222-3333-4444-555555555556'
    assert_equal 'There was a problem printing your barcodes. Your Tag Plates have still been created. There was an issue with printing', flash[:danger]
  end

  test 'create with no user' do
    api.mock_user('123456789', '11111111-2222-3333-4444-555555555555')
    post :create, params: {
         lot_id: '11111111-2222-3333-4444-555555555556',
         plate_number: 10
    }
    assert_redirected_to :root
    assert_equal 'User swipecard must be provided.', flash[:danger]
  end

  test '#create with fake user' do
    api.mock_user('123456789', '11111111-2222-3333-4444-555555555555')
    post :create, params: {
         user_swipecard: 'fake_user',
         lot_id: '11111111-2222-3333-4444-555555555556',
         plate_number: 10
    }
    assert_redirected_to :root
    assert_equal 'User could not be found, is your swipecard registered?', flash[:danger]
  end

  test 'create_qcable_creator' do
    api.mock_user('abcdef', '11111111-2222-3333-4444-555555555555')

    mock_lot = Sequencescape::Api::V2::Lot.new(lot_type_name: 'Tags')
    mock_lot.lot_type = Sequencescape::Api::V2::LotType.new
    mock_lot.lot_type.qcable_name = 'Tag Plate'
    
    Sequencescape::Api::V2::User.expects(:where).returns([Sequencescape::Api::V2::User.new])
    Sequencescape::Api::V2::Lot.expects(:where).returns([mock_lot])
    Sequencescape::Api::V2::BarcodePrinter.expects(:where).returns([Sequencescape::Api::V2::BarcodePrinter.new])
    mock_qcable_creator = Sequencescape::Api::V2::QcableCreator.new
    Sequencescape::Api::V2::QcableCreator.expects(:new).returns(mock_qcable_creator)
    mock_qcable_creator.expects(:save).returns(true)
    mock_qcable_creator.expects(:qcables).returns((1..10).map { Sequencescape::Api::V2::Qcable.new })

    # self.expects(:print_labels).returns(nil) # temp
    Rails.logger.expects(:error).never

    post :create, params: {
         user_swipecard: 'abcdef',
         lot_id: '11111111-2222-3333-4444-555555555556',
         plate_number: 10,
         barcode_printer: 'baac0dea-0000-0000-0000-000000000000'
    }
    assert_redirected_to controller: :lots, action: :show, id: '11111111-2222-3333-4444-555555555556'
    assert_nil flash[:danger]
    assert_equal '10 Tag Plates have been created.', flash[:success]
  end

  test 'create_qcable_creator_fail' do
    # mock out Sequencescape::Api::V2::User.where(uuid: @user.id).first
    # mock out Sequencescape::Api::V2::Lot.where(uuid: @lot.id).first

    # mock out qc_creator.save to return false
    # check is flash danger
    # check is error logging
    # check returns nil
  end

  test 'create_qcable_creator_exception' do
    # mock out Sequencescape::Api::V2::User.where(uuid: @user.id).first
    # mock out Sequencescape::Api::V2::Lot.where(uuid: @lot.id).first 

    # mock out qc_creator.save to raise an exception
    # check is flash danger
    # check is error logging
    # check returns nil
  end

  test 'upload' do
    api.mock_user('abcdef', '11111111-2222-3333-4444-555555555555')

    test_file = Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'test_file.xlsx'), '')
    plate_uploader = PlateUploader.new(test_file)

    api.qcable_creator.expect_create_with(
      received: {
        user: '11111111-2222-3333-4444-555555555555',
        lot: '11111111-2222-3333-4444-555555555556',
        barcodes: plate_uploader.payload
      },
      returns: '11111111-2222-3333-4444-555555555558'
    )

    post :upload, params: {
         user_swipecard: 'abcdef',
         lot_id: '11111111-2222-3333-4444-555555555556',
         upload: test_file
    }

    assert_redirected_to controller: :lots, action: :show, id: '11111111-2222-3333-4444-555555555556'
    assert_equal "#{plate_uploader.barcodes.length} Tag Plates have been created.", flash[:success]
  end
end
