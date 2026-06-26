# frozen_string_literal: true

require 'rails_helper'
require_relative 'lots_feature_shared'

RSpec.describe 'Lot show actions', type: :feature, js: true do
  include_context 'lots feature api stubs'

  it 'creates qcables from the lot show page' do
    lot_uuid = '11111111-2222-3333-4444-555555555556'
    shown_lot = stub_lot_show(
      lot_uuid:,
      lot_number: 'PST-12345',
      lot_type_name: 'Pre Stamped Tags'
    )
    created_qcables = Array.new(2) do |index|
      Sequencescape::Api::V2::Qcable.new.tap do |qcable|
        barcode = "DN#{index + 1}"
        qcable.labware_barcode = { human_barcode: barcode, machine_barcode: barcode }
      end
    end
    qcable_creator = Sequencescape::Api::V2::QcableCreator.new
    printer = Sequencescape::Api::V2::BarcodePrinter.new(print_service: 'PMB', name: 'Test Printer',
                                                         barcode_type: 'something')
    printer.uuid = 'baac0dea-0000-0000-0000-000000000000' if printer.respond_to?(:uuid=)

    allow(Sequencescape::Api::V2::Lot).to receive(:where).with(uuid: lot_uuid).and_return([shown_lot])
    allow(Sequencescape::Api::V2::User).to receive(:where).with(uuid: '11111111-2222-3333-4444-555555555555')
                                                          .and_return([Sequencescape::Api::V2::User.new])
    expect(Sequencescape::Api::V2::QcableCreator).to receive(:new).with({ count: 2 }).and_return(qcable_creator)
    allow(qcable_creator).to receive(:save).and_return(true)
    allow(qcable_creator).to receive(:qcables).and_return(created_qcables)
    allow(Sequencescape::Api::V2::BarcodePrinter).to receive(:where)
      .with(uuid: 'baac0dea-0000-0000-0000-000000000000')
      .and_return([printer])
    allow_any_instance_of(BarcodeSheet).to receive(:print!).and_return(true)

    visit lot_path(lot_uuid)
    within("form[action='#{lot_qcables_path(lot_uuid)}']") do
      fill_in 'user_swipecard', with: 'abcdef'
      fill_in 'plate_number', with: '2'
      select 'plate_example', from: 'barcode_printer'
      click_button 'Create Pre Stamped Tag Plates and Print Barcodes'
    end

    expect(page).to have_current_path("/lots/#{lot_uuid}", ignore_query: false)
    expect(page).to have_content('2 Pre Stamped Tag Plates have been created.')
  end

  it 'prints selected barcodes from the lot show page' do
    lot_uuid = '11111111-2222-3333-4444-555555555556'
    qcable = Sequencescape::Api::V2::Qcable.new(
      state: 'created',
      uuid: '11111111-2222-3333-4444-100000000001',
      labware_barcode: { 'human_barcode' => 'DN1' },
      stamp_index: nil
    )
    stub_lot_show(
      lot_uuid:,
      lot_number: 'PST-12345',
      lot_type_name: 'Pre Stamped Tags',
      qcables: [qcable]
    )
    printer = Sequencescape::Api::V2::BarcodePrinter.new(print_service: 'PMB', name: 'Test Printer',
                                                         barcode_type: 'something')
    allow(Sequencescape::Api::V2::BarcodePrinter).to receive(:where)
      .with(uuid: 'baac0dea-0000-0000-0000-000000000000')
      .and_return([printer])
    allow_any_instance_of(BarcodeSheet).to receive(:print!).and_return(true)

    visit lot_path(lot_uuid)
    within('.barcode-printing-form') do
      find("input[name='barcodes[DN1]']").check
      select 'plate_example', from: 'barcode_printer'
      click_button 'Print'
    end

    expect(page).to have_content('Your barcodes have been printed')
  end

  it 'creates an IDT tag plate from upload when one does not exist' do
    lot_uuid = '11111111-2222-3333-4444-555555555556'
    shown_lot = stub_lot_show(
      lot_uuid:,
      lot_number: 'PST-12345',
      lot_type_name: 'Pre Stamped Tags',
      qcables: []
    )
    upload_path = Rails.root.join('test/fixtures/test_file.xlsx')
    payload = PlateUploader.new(Rack::Test::UploadedFile.new(upload_path, '')).payload
    qcable_creator = Sequencescape::Api::V2::QcableCreator.new
    created_qcables = Array.new(2) { Sequencescape::Api::V2::Qcable.new }

    allow(Sequencescape::Api::V2::Lot).to receive(:where).with(uuid: lot_uuid).and_return([shown_lot])
    allow(Sequencescape::Api::V2::User).to receive(:where).with(uuid: '11111111-2222-3333-4444-555555555555')
                                                          .and_return([Sequencescape::Api::V2::User.new])
    expect(Sequencescape::Api::V2::QcableCreator).to receive(:new).with({ barcodes: payload })
                                                                  .and_return(qcable_creator)
    allow(qcable_creator).to receive(:save).and_return(true)
    allow(qcable_creator).to receive(:qcables).and_return(created_qcables)

    visit lot_path(lot_uuid)
    within("form[action='#{upload_lot_qcables_path(lot_uuid)}']") do
      fill_in 'user_swipecard', with: 'abcdef'
      attach_file 'upload', upload_path
      click_button 'Create IDT Tag Plate'
    end

    expect(page).to have_current_path("/lots/#{lot_uuid}", ignore_query: false)
    expect(page).to have_content('2 Pre Stamped Tag Plates have been created.')
  end
end
