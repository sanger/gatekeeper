# frozen_string_literal: true

require 'test_helper'
require 'mock_api'
require_relative '../support/pmb_support'

class BarcodeSheetTest < ActiveSupport::TestCase
  include MockApi

  setup do
    # PMB::TestSuiteStubs = Faraday::Adapter::Test::Stubs.new
    # PMB::Base.connection.delete(Faraday::Adapter::NetHttp)
    # PMB::Base.connection.faraday.adapter :test, PMB::TestSuiteStubs

    @printer_name = 'printer'
    @label_template_name = 'sqsc_96plate_label_template_code39'
    @label_template_id = '1'
    @label_template_query = { 'filter[name]': @label_template_name, 'page[page]': 1, 'page[per_page]': 1 }
    @label_template_url = "/v1/label_templates?#{URI.encode_www_form(@label_template_query)}"
  end

  test '#print!' do
    Timecop.freeze(Date.parse('02-02-2019')) do
      recieved_labels = [BarcodeSheet::Label.new(barcode: 'DN1S', prefix: 'DN', number: '1', lot: 'lot_number', template: 'tag_set')]

      sent_labels = [{
        top_left: '02-Feb-2019',
        bottom_left: 'DN1S',
        top_right: 'DN1S',
        bottom_right: 'lot_number:tag_set',
        barcode: 'DN1S'
      }]

      printer = api.barcode_printer.find('baac0dea-0000-0000-0000-000000000000')

      # PMB::TestSuiteStubs.get(@label_template_url) do |_env|
      #   [
      #     200,
      #     { content_type: 'application/json' },
      #     PmbSupport.label_template_response(@label_template_id, @label_template_name)
      #   ]
      # end

      # PMB::TestSuiteStubs.post('/v1/print_jobs', PmbSupport.print_job_post('plate_example', @label_template_id, sent_labels)) do |_env|
      #   [
      #     200,
      #     { content_type: 'application/json' },
      #     PmbSupport.print_job_response('plate_example', @label_template_id, sent_labels)
      #   ]
      # end

      BarcodeSheet.new(printer, recieved_labels).print!

      # PMB::TestSuiteStubs.verify_stubbed_calls
    end
  end
end
