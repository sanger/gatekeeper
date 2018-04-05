# frozen_string_literal: true

##
# BarcodeSheet takes:
# printer => A Sequencescape Client Api Printer object
# barcodes  => An array of desired barcode labels
class BarcodeSheet
  class PrintError < StandardError; end

  attr_reader :printer, :barcodes, :service
  private :service

  def initialize(printer, barcodes)
    @printer = printer
    @barcodes = barcodes
    @service = Sanger::Barcode::Printing::Service.new(@printer.service.url)
  end

  def printer_name
    printer.name
  end

  def printer_layout
    @printer.type.layout
  end

  def print!
    service.print_labels(barcodes, printer_name, printer_layout) unless ENV['STUB_PRINTING']
    true
  end
end
