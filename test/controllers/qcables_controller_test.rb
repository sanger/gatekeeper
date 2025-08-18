# frozen_string_literal: true

require 'test_helper'
require 'mock_api'

class QcablesControllerTest < ActionController::TestCase
  include MockApi

  setup do
    mock_api
  end

  test 'create' do
    # Mock finding the user through the API.
    # Both V1 and V2 versions needed for now.
    api.mock_user('abcdef', '11111111-2222-3333-4444-555555555555')
    Sequencescape::Api::V2::User.expects(:where).returns([Sequencescape::Api::V2::User.new])

    # Mock finding the Lot and Lot Type through the API (QCable Creator is created under a particular Lot).
    mock_lot = Sequencescape::Api::V2::Lot.new(lot_type_name: 'Tags', lot_number: '123456789', template_name: 'Example Tag Layout')
    mock_lot.lot_type = Sequencescape::Api::V2::LotType.new
    mock_lot.lot_type.qcable_name = 'Tag Plate'
    Sequencescape::Api::V2::Lot.expects(:where).returns([mock_lot])

    # Mock the QCableCreator creation and saving.
    mock_qcable_creator = Sequencescape::Api::V2::QcableCreator.new
    Sequencescape::Api::V2::QcableCreator.expects(:new).returns(mock_qcable_creator)
    mock_qcable_creator.expects(:save).returns(true)

    # Mock the retrieving of the QCables that would have been created (including barcodes).
    qcables = (1..10).map { Sequencescape::Api::V2::Qcable.new }
    qcables.each_with_index do |qcable, index|
      barcode = "DN#{index + 1}"
      qcable.labware_barcode = { human_barcode: barcode, machine_barcode: barcode }
    end
    mock_qcable_creator.expects(:qcables).returns(qcables).at_least_once

    # Mock the barcode label printing calls.
    Sequencescape::Api::V2::BarcodePrinter.expects(:where).returns([Sequencescape::Api::V2::BarcodePrinter.new(print_service: 'PMB', name: 'Test Printer', barcode_type: 'something')])
    mock_barcode_sheet = mock('printer')
    mock_barcode_sheet.expects(:print!).returns(true)
    BarcodeSheet.expects(:new).returns(mock_barcode_sheet)

    # Make the call, which qcables_controller would receive from the form submission.
    post :create, params: {
         user_swipecard: 'abcdef',
         lot_id: '11111111-2222-3333-4444-555555555556',
         plate_number: 10,
         barcode_printer: 'baac0dea-0000-0000-0000-000000000000'
    }

    # Check the response and flash messages.
    assert_redirected_to controller: :lots, action: :show, id: '11111111-2222-3333-4444-555555555556'
    assert_nil flash[:danger]
    assert_equal '10 Tag Plates have been created.', flash[:success]
  end

  test 'create when BarcodeSheet.print! errors' do
    # Mock finding the user through the API.
    # Both V1 and V2 versions needed for now.
    api.mock_user('abcdef', '11111111-2222-3333-4444-555555555555')
    Sequencescape::Api::V2::User.expects(:where).returns([Sequencescape::Api::V2::User.new])

    # Mock finding the Lot and Lot Type through the API (QCable Creator is created under a particular Lot).
    mock_lot = Sequencescape::Api::V2::Lot.new(lot_type_name: 'Tags', lot_number: '123456789', template_name: 'Example Tag Layout')
    mock_lot.lot_type = Sequencescape::Api::V2::LotType.new
    mock_lot.lot_type.qcable_name = 'Tag Plate'
    Sequencescape::Api::V2::Lot.expects(:where).returns([mock_lot])

    # Mock the QCableCreator creation and saving.
    mock_qcable_creator = Sequencescape::Api::V2::QcableCreator.new
    Sequencescape::Api::V2::QcableCreator.expects(:new).returns(mock_qcable_creator)
    mock_qcable_creator.expects(:save).returns(true)

    # Mock the retrieving of the QCables that would have been created (including barcodes).
    qcables = (1..10).map { Sequencescape::Api::V2::Qcable.new }
    qcables.each_with_index do |qcable, index|
      barcode = "DN#{index + 1}"
      qcable.labware_barcode = { human_barcode: barcode, machine_barcode: barcode }
    end
    mock_qcable_creator.expects(:qcables).returns(qcables).at_least_once

    # Mock the barcode label printing calls.
    Sequencescape::Api::V2::BarcodePrinter.expects(:where).returns([Sequencescape::Api::V2::BarcodePrinter.new(print_service: 'PMB', name: 'Test Printer', barcode_type: 'something')])
    mock_barcode_sheet = mock('printer')
    mock_barcode_sheet.expects(:print!).raises(BarcodeSheet::PrintError, 'There was an issue with printing')
    BarcodeSheet.expects(:new).returns(mock_barcode_sheet)

    # Make the call, which qcables_controller would receive from the form submission.
    post :create, params: {
         user_swipecard: 'abcdef',
         lot_id: '11111111-2222-3333-4444-555555555556',
         plate_number: 10,
         barcode_printer: 'baac0dea-0000-0000-0000-000000000000'
    }

    # Check the response and flash messages.
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

  test 'create with fake user' do
    api.mock_user('123456789', '11111111-2222-3333-4444-555555555555')
    post :create, params: {
         user_swipecard: 'fake_user',
         lot_id: '11111111-2222-3333-4444-555555555556',
         plate_number: 10
    }
    assert_redirected_to :root
    assert_equal 'User could not be found, is your swipecard registered?', flash[:danger]
  end

  test 'create when save fails' do
    # Mock finding the user through the API.
    # Both V1 and V2 versions needed for now.
    api.mock_user('abcdef', '11111111-2222-3333-4444-555555555555')
    Sequencescape::Api::V2::User.expects(:where).returns([Sequencescape::Api::V2::User.new])

    # Mock finding the Lot and Lot Type through the API (QCable Creator is created under a particular Lot).
    mock_lot = Sequencescape::Api::V2::Lot.new(lot_type_name: 'Tags', lot_number: '123456789', template_name: 'Example Tag Layout')
    mock_lot.lot_type = Sequencescape::Api::V2::LotType.new
    mock_lot.lot_type.qcable_name = 'Tag Plate'
    Sequencescape::Api::V2::Lot.expects(:where).returns([mock_lot])

    # Mock the QCableCreator creation and saving.
    mock_qcable_creator = Sequencescape::Api::V2::QcableCreator.new
    Sequencescape::Api::V2::QcableCreator.expects(:new).returns(mock_qcable_creator)
    mock_qcable_creator.expects(:save).returns(false)

    # Mock the finding of the barcode printer.
    Sequencescape::Api::V2::BarcodePrinter.expects(:where).returns([Sequencescape::Api::V2::BarcodePrinter.new(print_service: 'PMB', name: 'Test Printer', barcode_type: 'something')])

    # Make the call, which qcables_controller would receive from the form submission.
    post :create, params: {
         user_swipecard: 'abcdef',
         lot_id: '11111111-2222-3333-4444-555555555556',
         plate_number: 10,
         barcode_printer: 'baac0dea-0000-0000-0000-000000000000'
    }

    # Check the response and flash messages.
    assert_redirected_to controller: :lots, action: :show, id: '11111111-2222-3333-4444-555555555556'
    assert_equal 'There was a problem creating plates in Sequencescape.', flash[:danger]
    assert_nil flash[:success]
  end

  test 'create when save raises exception' do
    # mock out Sequencescape::Api::V2::User.where(uuid: @user.id).first
    # mock out Sequencescape::Api::V2::Lot.where(uuid: @lot.id).first

    # mock out qc_creator.save to raise an exception
    # check is flash danger

    # Mock finding the user through the API.
    # Both V1 and V2 versions needed for now.
    api.mock_user('abcdef', '11111111-2222-3333-4444-555555555555')
    Sequencescape::Api::V2::User.expects(:where).returns([Sequencescape::Api::V2::User.new])

    # Mock finding the Lot and Lot Type through the API (QCable Creator is created under a particular Lot).
    mock_lot = Sequencescape::Api::V2::Lot.new(lot_type_name: 'Tags', lot_number: '123456789', template_name: 'Example Tag Layout')
    mock_lot.lot_type = Sequencescape::Api::V2::LotType.new
    mock_lot.lot_type.qcable_name = 'Tag Plate'
    Sequencescape::Api::V2::Lot.expects(:where).returns([mock_lot])

    # Mock the QCableCreator creation and saving.
    mock_qcable_creator = Sequencescape::Api::V2::QcableCreator.new
    Sequencescape::Api::V2::QcableCreator.expects(:new).returns(mock_qcable_creator)
    mock_qcable_creator.expects(:save).raises(StandardError.new('Some error'))

    # Mock the finding of the barcode printer.
    Sequencescape::Api::V2::BarcodePrinter.expects(:where).returns([Sequencescape::Api::V2::BarcodePrinter.new(print_service: 'PMB', name: 'Test Printer', barcode_type: 'something')])

    # Make the call, which qcables_controller would receive from the form submission.
    post :create, params: {
         user_swipecard: 'abcdef',
         lot_id: '11111111-2222-3333-4444-555555555556',
         plate_number: 10,
         barcode_printer: 'baac0dea-0000-0000-0000-000000000000'
    }

    # Check the response and flash messages.
    assert_redirected_to controller: :lots, action: :show, id: '11111111-2222-3333-4444-555555555556'
    assert_equal 'There was a problem creating plates in Sequencescape.', flash[:danger]
    assert_nil flash[:success]
  end

  test 'upload' do
    api.mock_user('abcdef', '11111111-2222-3333-4444-555555555555')
    Sequencescape::Api::V2::User.expects(:where).returns([Sequencescape::Api::V2::User.new])

    test_file = Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'test_file.xlsx'), '')
    plate_uploader = PlateUploader.new(test_file)

    # Mock finding the Lot and Lot Type through the API (QCable Creator is created under a particular Lot).
    mock_lot = Sequencescape::Api::V2::Lot.new(lot_type_name: 'Tags', lot_number: '123456789', template_name: 'Example Tag Layout')
    mock_lot.lot_type = Sequencescape::Api::V2::LotType.new
    mock_lot.lot_type.qcable_name = 'Tag Plate'
    Sequencescape::Api::V2::Lot.expects(:where).returns([mock_lot])

    # Mock the QCableCreator creation and saving.
    mock_qcable_creator = Sequencescape::Api::V2::QcableCreator.new
    Sequencescape::Api::V2::QcableCreator.expects(:new).returns(mock_qcable_creator)
    mock_qcable_creator.expects(:save).returns(true)

    # Mock the retrieving of the QCables that would have been created (including barcodes).
    qcables = (1..10).map { Sequencescape::Api::V2::Qcable.new }
    qcables.each_with_index do |qcable, index|
      barcode = "DN#{index + 1}"
      qcable.labware_barcode = { human_barcode: barcode, machine_barcode: barcode }
    end
    mock_qcable_creator.expects(:qcables).returns(qcables).at_least_once

    post :upload, params: {
         user_swipecard: 'abcdef',
         lot_id: '11111111-2222-3333-4444-555555555556',
         upload: test_file
    }

    assert_redirected_to controller: :lots, action: :show, id: '11111111-2222-3333-4444-555555555556'
    assert_equal "#{plate_uploader.barcodes.length} Tag Plates have been created.", flash[:success]
  end
end
