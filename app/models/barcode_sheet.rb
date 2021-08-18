# frozen_string_literal: true

require 'net/http'

##
# BarcodeSheet takes:
# printer => A Sequencescape Client Api Printer object
# labels  => An array of desired barcode labels

# to update communication here
# update template lookup
# same name on squix
class BarcodeSheet
  class PrintError < StandardError; end

  attr_reader :printer, :labels

  # validates_presence_of :printer, :locations, :label_template_name
  # validates_numericality_of :copies, greater_than: 0

  def initialize(printer, labels)
    @printer = printer
    @labels = labels
  end

  def print!
    post || raise(PrintError, @errors)
    # job.save || raise(PrintError, job.errors.full_messages.join('; '))
  end

  private

  def config
    # printer_type 96 or tube
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
    # PMB::PrintJob.new(
    #   printer_name: printer_name,
    #   label_template_id: label_template_id,
    #   labels: { body: all_labels }
    # )
  end

  ##
  # Post the request to the barcode service.
  # Will return true if successful
  # Will return false if there is either an unexpected error or a server error
  def post
    return unless valid?

    begin
      response = Net::HTTP.post URI("#{Rails.configuration.pmb_uri}/print_jobs"),
                                body.to_json,
                                'Content-Type' => 'application/json'
      if response.code == '200'
        true
      else
        @errors = JSON.parse(response.body)
        false
      end
    rescue StandardError
      false
    end
  end

  def all_labels
    labels.map(&label_method)
  end

  # def label_template_id
  #   # This isn't a rails finder; so we disable the cop.
  #   PMB::LabelTemplate.where(name: config[:template]).first.id
  # rescue JsonApiClient::Errors::ConnectionError => e
  #   Rails.logger.error(e.message)
  #   raise PrintError, 'PrintMyBarcode service is down'
  # end

  def printer_name
    printer.name
  end

  def printer_type
    @printer.type.name
  end

  def body
    @body ||= {
      print_job: {
        printer_name: printer_name,
        label_template_name: label_template_name,
        labels: all_labels,
        copies: copies
      }
    }
  end
end
