# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Lot show actions', type: :feature, js: true do
  include MockApiV2

  let(:user) { MockApiV2.mock_user(swipecard: 'abcdef') }
  let(:user_swipecard) { user.swipecard }

  def build_shown_lot(lot_uuid:, lot_number:, lot_type_name:, qcables: [])
    shown_lot_type = Sequencescape::Api::V2::LotType.new(
      qcable_name: 'Pre Stamped Tag Plate',
      printer_type: '96 Well Plate'
    )
    shown_lot = Sequencescape::Api::V2::Lot.new(
      uuid: lot_uuid,
      lot_number: lot_number,
      lot_type_name: lot_type_name,
      template_name: 'Example Tag Template',
      received_at: Date.new(2026, 6, 26)
    )
    allow(shown_lot).to receive(:lot_type).and_return(shown_lot_type)
    allow(shown_lot).to receive(:qcables).and_return(qcables)
    shown_lot
  end

  def stub_lot_show(lot_uuid:, lot_number:, lot_type_name:, qcables: [])
    shown_lot = build_shown_lot(
      lot_uuid:,
      lot_number:,
      lot_type_name:,
      qcables:
    )

    MockApiV2.mock_lots_controller_find_lot(shown_lot)

    shown_lot
  end

  it 'shows a lot with its details' do
    lot_uuid = '11111111-2222-3333-4444-555555555556'
    stub_lot_show(
      lot_uuid:,
      lot_number: 'PST-12345',
      lot_type_name: 'Pre Stamped Tags'
    )

    visit lot_path(lot_uuid)

    within('.gk-section', text: 'Summary') do
      expect(page).to have_css('h2', text: 'Summary')
      expect(page).to have_css('#lot_number', text: 'PST-12345')
      expect(page).to have_css('#lot_template', text: 'Example Tag Template')
      expect(page).to have_css('#lot_received_at', text: '26/06/2026')
    end
  end

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
      fill_in 'user_swipecard', with: user_swipecard
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
    expect(Sequencescape::Api::V2::QcableCreator).to receive(:new).with({ barcodes: payload })
                                                                  .and_return(qcable_creator)
    allow(qcable_creator).to receive(:save).and_return(true)
    allow(qcable_creator).to receive(:qcables).and_return(created_qcables)

    visit lot_path(lot_uuid)
    within("form[action='#{upload_lot_qcables_path(lot_uuid)}']") do
      fill_in 'user_swipecard', with: user_swipecard
      attach_file 'upload', upload_path
      click_button 'Create IDT Tag Plate'
    end

    expect(page).to have_current_path("/lots/#{lot_uuid}", ignore_query: false)
    expect(page).to have_content('2 Pre Stamped Tag Plates have been created.')
  end
end
