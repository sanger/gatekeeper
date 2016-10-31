require 'test_helper'
require 'mock_api'

class BarcodeSheetTest < ActiveSupport::TestCase

  include MockApi

  setup do
    mock_api
  end


  test "#print!" do

    labels = [Sanger::Barcode::Printing::Label.new(prefix: 'DN',number: 1,study: "test")]

    mock_service = mock('service')
    mock_service.expects(:print_labels).with(labels, 'plate_example', 1)
    Sanger::Barcode::Printing::Service.expects(:new).with('http://localhost/mock_service.wsdl').returns(mock_service)

    printer = api.barcode_printer.find('baac0dea-0000-0000-0000-000000000000')

    BarcodeSheet.new(printer,labels).print!
  end


end
