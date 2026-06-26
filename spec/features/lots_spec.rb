# frozen_string_literal: true

require 'rails_helper'

TemplateScope = Struct.new(:templates) do
  def all
    templates
  end
end

UserSearchScope = Struct.new(:user) do
  def first(swipecard_code:)
    swipecard_code == 'abcdef' ? user : nil
  end
end

SearchScope = Struct.new(:user_search_scope) do
  def find(_search_name)
    user_search_scope
  end
end

ApiStub = Struct.new(:search, :tag_layout_template)

LotScope = Struct.new(:lots) do
  def where(uuid:)
    lots.select { |lot| lot.uuid == uuid }
  end
end

RSpec.describe 'Lot registration pages', type: :feature, js: true do
  before do
    allow(Sequencescape::Api).to receive(:new).and_return(api)
  end

  # API V2 User
  # let(:user) { Sequencescape::Api::V2::User.new(uuid: '11111111-2222-3333-4444-555555555555') }
  let(:user) do
    Sequencescape::User.new({}).tap do |sequencescape_user|
      allow(sequencescape_user).to receive(:id).and_return('11111111-2222-3333-4444-555555555555')
      allow(sequencescape_user).to receive(:uuid).and_return('11111111-2222-3333-4444-555555555555')
    end
  end
  let(:tag_templates) do
    [
      Sequencescape::Api::V2::TagLayoutTemplate.new(
        name: 'Example Tag Template',
        uuid: 'ecd5cd30-956f-11e3-8255-44fb42fffecc',
        walking_by: 'wells of plate'
      ),
      Sequencescape::Api::V2::TagLayoutTemplate.new(
        name: 'Another Tag Layout',
        uuid: 'ecd7a1f0-956f-11e3-8255-44fb42fffecc',
        walking_by: 'quadrants'
      )
    ]
  end
  let(:template_scope) { TemplateScope.new(tag_templates) }
  let(:user_search_scope) { UserSearchScope.new(user) }
  let(:search_scope) { SearchScope.new(user_search_scope) }
  let(:api) { ApiStub.new(search_scope, template_scope) }

  before do
    allow(search_scope).to receive(:find).with(Settings.searches['Find user by swipecard code']).and_call_original
    allow(user_search_scope).to receive(:first).with(swipecard_code: 'abcdef').and_call_original
  end

  def stub_lot_submission_and_redirect(created_lot_uuid:, created_lot_number:, lot_type_name:, lot_type_uuid:)
    selected_template = Sequencescape::Api::V2::TagLayoutTemplate.new(
      id: 42,
      name: 'Example Tag Template',
      uuid: 'ecd5cd30-956f-11e3-8255-44fb42fffecc'
    )
    created_lot = Sequencescape::Api::V2::Lot.new(
      user_uuid: '11111111-2222-3333-4444-555555555555',
      lot_number: created_lot_number,
      lot_type_uuid: lot_type_uuid,
      template_type: 'TagLayoutTemplate',
      template_id: 42,
      received_at: '2026-06-26'
    )
    shown_lot_type = Sequencescape::Api::V2::LotType.new(
      qcable_name: 'Pre Stamped Tag Plate',
      printer_type: '96 Well Plate'
    )
    shown_lot = Sequencescape::Api::V2::Lot.new(
      lot_number: created_lot_number,
      uuid: created_lot_uuid,
      lot_type_name: lot_type_name,
      template_name: 'Example Tag Template',
      received_at: Date.new(2026, 6, 26)
    )
    allow(shown_lot).to receive(:lot_type).and_return(shown_lot_type)
    allow(shown_lot).to receive(:qcables).and_return([])
    lot_scope = LotScope.new([shown_lot])

    allow(Sequencescape::Api::V2::TagLayoutTemplate).to receive(:find)
      .with(uuid: 'ecd5cd30-956f-11e3-8255-44fb42fffecc')
      .and_return([selected_template])

    expect(Sequencescape::Api::V2::Lot).to receive(:new).with(
      user_uuid: '11111111-2222-3333-4444-555555555555',
      lot_number: created_lot_number,
      lot_type_uuid: lot_type_uuid,
      template_type: 'TagLayoutTemplate',
      template_id: 42,
      received_at: '2026-06-26'
    ).and_return(created_lot)
    allow(created_lot).to receive(:save) do
      created_lot.uuid = created_lot_uuid
      true
    end

    allow(Sequencescape::Api::V2::Lot).to receive(:includes).with(:lot_type, :qcables).and_return(lot_scope)
  end

  def stub_lot_search_and_show(found_lot_uuid:, found_lot_number:, lot_type_name:)
    found_lot = Sequencescape::Api::V2::Lot.new(uuid: found_lot_uuid)
    shown_lot_type = Sequencescape::Api::V2::LotType.new(
      qcable_name: 'Pre Stamped Tag Plate',
      printer_type: '96 Well Plate'
    )
    shown_lot = Sequencescape::Api::V2::Lot.new(
      uuid: found_lot_uuid,
      lot_number: found_lot_number,
      lot_type_name: lot_type_name,
      template_name: 'Example Tag Template',
      received_at: Date.new(2026, 6, 26)
    )
    allow(shown_lot).to receive(:lot_type).and_return(shown_lot_type)
    allow(shown_lot).to receive(:qcables).and_return([])

    allow(Sequencescape::Api::V2::Lot).to receive(:find).with(lot_number: found_lot_number).and_return([found_lot])
    allow(Sequencescape::Api::V2::Lot)
      .to receive(:includes).with(:lot_type, :qcables)
                            .and_return(LotScope.new([shown_lot]))
  end

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

    allow(Sequencescape::Api::V2::Lot)
      .to receive(:includes).with(:lot_type, :qcables)
                            .and_return(LotScope.new([shown_lot]))
    shown_lot
  end

  it 'submits the Pre Stamped Tags lot registration form' do
    created_lot_uuid = '11111111-2222-3333-4444-555555555556'
    created_lot_number = 'PST-12345'
    stub_lot_submission_and_redirect(
      created_lot_uuid:,
      created_lot_number:,
      lot_type_name: 'Pre Stamped Tags',
      lot_type_uuid: '0eb10418-ff2e-11ef-99ca-060cfcc4e0a0'
    )

    visit new_lot_path(lot_type: 'Pre Stamped Tags')
    within('#gk-new-lot-page form') do
      fill_in 'user_swipecard', with: 'abcdef'
      fill_in 'lot_number', with: created_lot_number
      select 'Example Tag Template', from: 'template'
      fill_in 'received_at', with: '26/06/2026'
      click_button 'Register Lot'
    end

    expect(page).to have_current_path("/lots/#{created_lot_uuid}", ignore_query: false)
    expect(page).to have_css('h1', text: 'Pre Stamped Tags: PST-12345')
    expect(page).to have_css('#lot_number', text: 'PST-12345')
  end

  it 'finds a lot from the nav bar lot number box' do
    found_lot_uuid = '11111111-2222-3333-4444-555555555556'
    found_lot_number = 'PST-12345'
    stub_lot_search_and_show(
      found_lot_uuid:,
      found_lot_number:,
      lot_type_name: 'Pre Stamped Tags'
    )

    visit new_lot_path(lot_type: 'Pre Stamped Tags')
    within('form.navbar-form') do
      find("input[name='lot_number']").set(found_lot_number)
      click_button 'Find'
    end

    expect(page).to have_current_path("/lots/#{found_lot_uuid}", ignore_query: false)
    expect(page).to have_css('h1', text: 'Pre Stamped Tags: PST-12345')
    expect(page).to have_css('#lot_number', text: 'PST-12345')
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
    expect(Sequencescape::Api::V2::QcableCreator).to receive(:new).with({ barcodes: payload }).and_return(qcable_creator)
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

  it 'submits the Pre Stamped Tags - 384 lot registration form' do
    created_lot_uuid = '11111111-2222-3333-4444-555555555557'
    created_lot_number = 'PST384-12345'
    stub_lot_submission_and_redirect(
      created_lot_uuid:,
      created_lot_number:,
      lot_type_name: 'Pre Stamped Tags - 384',
      lot_type_uuid: '0eb27564-ff2e-11ef-99ca-060cfcc4e0a0'
    )

    visit new_lot_path(lot_type: 'Pre Stamped Tags - 384')
    within('#gk-new-lot-page form') do
      fill_in 'user_swipecard', with: 'abcdef'
      fill_in 'lot_number', with: created_lot_number
      select 'Example Tag Template', from: 'template'
      fill_in 'received_at', with: '26/06/2026'
      click_button 'Register Lot'
    end

    expect(page).to have_current_path("/lots/#{created_lot_uuid}", ignore_query: false)
    expect(page).to have_css('h1', text: 'Pre Stamped Tags - 384: PST384-12345')
    expect(page).to have_css('#lot_number', text: 'PST384-12345')
  end
end
