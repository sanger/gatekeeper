# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Lot registration', type: :feature, js: true do
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

    allow(Sequencescape::Api::V2::TagLayoutTemplate).to receive(:all).and_return([selected_template])
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

    allow(Sequencescape::Api::V2::Lot).to receive(:includes).with(:lot_type, :qcables).and_return([shown_lot])
  end

  before do
    MockApiV1.mock_api_v1
  end
  it 'submits the Pre Stamped Tags lot registration form' do
    swipecard_code = 'abcdef'
    MockApiV2.mock_user(swipecard: swipecard_code)

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
      fill_in 'user_swipecard', with: swipecard_code
      fill_in 'lot_number', with: created_lot_number
      select 'Example Tag Template', from: 'template'
      fill_in 'received_at', with: '26/06/2026'
      click_button 'Register Lot'
    end

    expect(page).to have_current_path("/lots/#{created_lot_uuid}", ignore_query: false)
    expect(page).to have_css('h1', text: 'Pre Stamped Tags: PST-12345')
    expect(page).to have_css('#lot_number', text: 'PST-12345')
  end

  it 'submits the Pre Stamped Tags - 384 lot registration form' do
    swipecard_code = 'abcdef'
    MockApiV2.mock_user(swipecard: swipecard_code)

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
      fill_in 'user_swipecard', with: swipecard_code
      fill_in 'lot_number', with: created_lot_number
      select 'Example Tag Template', from: 'template'
      fill_in 'received_at', with: '26/06/2026'
      click_button 'Register Lot'
    end

    expect(page).to have_current_path("/lots/#{created_lot_uuid}", ignore_query: false)
    expect(page).to have_css('h1', text: 'Pre Stamped Tags - 384: PST384-12345')
    expect(page).to have_css('#lot_number', text: 'PST384-12345')
  end

  it 'shows an error when the user swipecard is not found' do
    not_found_swipecard = 'non-existent-swipecard'
    MockApiV2.mock_missing_user(swipecard: not_found_swipecard)

    visit new_lot_path(lot_type: 'Pre Stamped Tags')
    within('#gk-new-lot-page form') do
      fill_in 'user_swipecard', with: not_found_swipecard
      # tab to next field to trigger validation
      send_keys :tab
      # shows a validation error on the form group when the user swipecard is not found
      expect(find('.form-group', text: 'User swipecard')['class']).to include('has-error')
      fill_in 'lot_number', with: 'PST-12345'
      select 'Example Tag Template', from: 'template'
      fill_in 'received_at', with: '26/06/2026'
      click_button 'Register Lot'
    end

    expect(page).to have_current_path('/')
    expect(page).to have_css('.alert.alert-danger',
                             text: 'User could not be found, is your swipecard registered?')
  end
end
