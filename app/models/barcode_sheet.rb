# frozen_string_literal: true

##
# BarcodeSheet takes:
# printer => A Sequencescape Client Api Printer object
# labels  => An array of desired barcode labels
class BarcodeSheet
  include ActiveModel::Model

  class PrintError < StandardError; end

  attr_reader :printer, :labels

  validates :printer, :labels, presence: true

  def initialize(printer, labels)
    @printer = printer
    @labels = labels
  end

  def print!
    return false unless valid?

    case printer.print_service
    when 'PMB'
      print_to_pmb
    when 'SPrint'
      print_to_sprint
    else
      raise(PrintError, "Print service #{printer.print_service} not recognised.")
    end
  end

  def print_to_pmb
    job.save || raise(PrintError, job.errors.full_messages.join('; '))
  end

  def print_to_sprint
    response = SPrintClient.send_print_request(
      printer_name,
      "#{label_template_name}.yml.erb",
      all_labels
    )
    raise(PrintError, 'There was an error sending a print request to SPrint') unless response.code == '200'
  end

  def sprint_labels
    all_labels.pluck(:main_label)
  end

  private

  def config
    Gatekeeper::Application.config.printer_type_options[printer_type] ||
      raise(PrintError, "Unknown printer type: #{printer_type}")
  end

  def label_method
    config[:label]
  end

  def label_template_name
    config[:template]
  end

  def job
    PMB::PrintJob.new(
      printer_name: printer_name,
      label_template_id: pmb_label_template_id,
      labels: { body: all_labels }
    )
  end

  def all_labels
    labels.map(&label_method)
  end

  def pmb_label_template_id
    # This isn't a rails finder; so we disable the cop.
    PMB::LabelTemplate.where(name: label_template_name).first.id
  rescue JsonApiClient::Errors::ConnectionError => e
    Rails.logger.error(e.message)
    raise PrintError, 'PrintMyBarcode service is down'
  end

  def printer_name
    printer.name
  end

  def printer_type
    @printer.type.name
  end
end
