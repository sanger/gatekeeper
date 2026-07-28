# frozen_string_literal: true

require 'test_helper'
require 'rake'

Rake::Task.define_task(:environment)

load Rails.root.join('lib/tasks/config.rake').to_s

class ConfigRakeTest < ActiveSupport::TestCase
  setup do
    Rake::Task['config:generate'].reenable
  end

  test 'config:generate writes the current searches printers and lot types' do
    active_printer = Sequencescape::Api::V2::BarcodePrinter.new(
      active: true,
      name: 'Printer 1',
      uuid: 'printer-uuid',
      barcode_type: 'barcode-type'
    )
    inactive_printer = Sequencescape::Api::V2::BarcodePrinter.new(
      active: false,
      name: 'Disabled printer',
      uuid: 'disabled-printer-uuid',
      barcode_type: 'barcode-type'
    )

    lot_type_a = Sequencescape::Api::V2::LotType.new(
      name: 'Lot Type A',
      uuid: 'lot-type-a-uuid',
      template_class: 'TemplateClassA',
      printer_type: 'PrinterTypeA',
      qcable_name: 'QcableNameA'
    )

    Gatekeeper::Application.config.stubs(:approved_printers).returns(['Printer 1'])
    Sequencescape::Api::V2::BarcodePrinter.expects(:all).returns([active_printer, inactive_printer])
    Sequencescape::Api::V2::LotType.expects(:all).returns([lot_type_a])

    root = mock('root')
    settings_file = mock('settings file')
    output_file = mock('output file')

    Rails.stubs(:root).returns(root)
    root.expects(:join).with('config', 'settings', 'test.yml').returns(settings_file)
    settings_file.expects(:open).with('w').yields(output_file)

    expected_config = {
      printers: {
        'barcode-type' => [
          {
            name: 'Printer 1',
            uuid: 'printer-uuid'
          }
        ]
      },
      lot_types: {
        'Lot Type A' => {
          uuid: 'lot-type-a-uuid',
          template_class: 'TemplateClassA',
          printer_type: 'PrinterTypeA',
          qcable_name: 'QcableNameA'
        }
      }
    }

    output_file.expects(:puts).with(expected_config.to_yaml)

    assert_output("Preparing printers ...\nPreparing lot types ...\n") do
      Rake::Task['config:generate'].invoke
    end
  end
end
