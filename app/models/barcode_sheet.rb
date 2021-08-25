# frozen_string_literal: true

require 'net/http'

##
# BarcodeSheet takes:
# printer => A Sequencescape Client Api Printer object
# labels  => An array of desired barcode labels
# copies => Currently supporting only 1 copy of a label
class BarcodeSheet
  class PrintError < StandardError; end

  attr_reader :printer, :labels, :copies

  def initialize(printer, labels)
    @printer = printer
    @labels = labels
    @copies = 1
  end

  def print!
    post || raise(PrintError, @errors.join('; '))
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

  ##
  # Post the request to the barcode service.
  # Will return true if successful
  # Will return false if there is either an unexpected error or a server error
  def post

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
      @errors = ["An unexpected error has occured"]
      false
    end
  end

  def all_labels
    labels.map(&label_method)
  end

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
