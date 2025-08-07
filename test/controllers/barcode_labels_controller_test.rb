# frozen_string_literal: true

require 'test_helper'

class BarcodeLabelsControllerTest < ActionController::TestCase
  include MockApi

  setup do
    mock_api
    printer = api.barcode_printer.find('baac0dea-0000-0000-0000-000000000000')
    printer.stubs(:print_service).returns('PMB')
    @params = {
      prefix: 'ABC',
      study: 'Study1',
      numbers: { '123' => '123', '456' => '456' },
      # Test printer name
      barcode_printer: 'baac0dea-0000-0000-0000-000000000000'
    }
  end

  test 'should print barcodes and return success' do
    mock_barcode_sheet = mock('printer')
    mock_barcode_sheet.expects(:print!).returns(true)
    BarcodeSheet.expects(:new).returns(mock_barcode_sheet)

    post :create, params: @params

    assert_response :success
    body = response.parsed_body
    assert_equal 'Your barcodes have been printed', body['success']
  end

  test 'should handle BarcodeSheet::PrintError' do
    mock_barcode_sheet = mock('printer')
    mock_barcode_sheet.expects(:print!).raises(BarcodeSheet::PrintError.new('Printer jammed'))
    BarcodeSheet.expects(:new).returns(mock_barcode_sheet)

    post :create, params: @params

    assert_response :success
    body = response.parsed_body
    assert_match(/There was a problem printing your barcodes/, body['error'])
    assert_match(/Printer jammed/, body['error'])
  end

  test 'should handle connection refused error' do
    mock_barcode_sheet = mock('printer')
    mock_barcode_sheet.expects(:print!).raises(Errno::ECONNREFUSED)
    BarcodeSheet.expects(:new).returns(mock_barcode_sheet)

    post :create, params: @params
    assert_response :success
    body = response.parsed_body
    assert_equal 'Could not connect to the barcode printing service.', body['error']
  end

  test 'should generate labels with correct attributes' do
    controller = BarcodeLabelsController.new
    params = ActionController::Parameters.new(@params)
    controller.params = params
    controller.send(:generate_labels)
    labels = controller.instance_variable_get(:@labels)
    assert_equal 2, labels.size
    assert_equal 'ABC', labels.first.instance_variable_get(:@prefix)
    assert_equal '123', labels.first.instance_variable_get(:@number)
    assert_equal 'Study1', labels.first.instance_variable_get(:@legacy_study)
  end
end
