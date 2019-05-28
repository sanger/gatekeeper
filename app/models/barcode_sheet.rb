# frozen_string_literal: true

##
# BarcodeSheet takes:
# printer => A Sequencescape Client Api Printer object
# barcodes  => An array of desired barcode labels
class BarcodeSheet
  class PrintError < StandardError; end

  attr_reader :printer, :barcodes

  def initialize(printer, barcodes)
    @printer = printer
    @barcodes = barcodes
  end

  def print!
    job.save || raise(PrintError, job.errors.full_messages.join('; '))
  end

  private

  def config
    Gatekeeper::Application.config.printer_type_options[printer_type] ||
      raise(PrintError, "Unknown printer type: #{printer_type}")
  end

  def label_method
    config[:label]
  end

  def job
    PMB::PrintJob.new(
      printer_name: printer_name,
      label_template_id: label_template_id,
      labels: { body: all_labels }
    )
  end

  def all_labels
    barcodes.map(&label_method)
  end

  def label_template_id
    # This isn't a rails finder; so we disable the cop.
    PMB::LabelTemplate.where(name: config[:template]).first.id # rubocop:disable Rails/FindBy
  rescue JsonApiClient::Errors::ConnectionError
    raise PrintError, 'PrintMyBarcode service is down'
  end

  def printer_name
    printer.name
  end

  def printer_type
    @printer.type.name
  end
end
