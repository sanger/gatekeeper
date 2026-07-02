# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages', type: :feature do
  let(:lot_number) { 'PST-12345' }

  it 'shows the landing page with used links' do
    visit root_path

    expect(page).to have_css('#gk-index-title', text: 'Gatekeeper')
    expect(page).to have_content('Register Lots')
    expect(page).to have_link('Register Pre Stamped Tags Lot')
    expect(page).to have_link('Register Pre Stamped Tags - 384 Lot')
    expect(page).to have_content('Other Actions')
    expect(page).to have_link('View Lot')
  end

  it 'finds and shows a lot from the View Lot form', js: true do
    lot_uuid = '11111111-2222-3333-4444-555555555556'
    found_lot = Sequencescape::Api::V2::Lot.new(uuid: lot_uuid)
    shown_lot_type = Sequencescape::Api::V2::LotType.new(
      qcable_name: 'Pre Stamped Tag Plate',
      printer_type: '96 Well Plate'
    )
    shown_lot = Sequencescape::Api::V2::Lot.new(
      uuid: lot_uuid,
      lot_number: lot_number,
      lot_type_name: 'Pre Stamped Tags',
      template_name: 'Example Tag Template',
      received_at: Date.new(2026, 6, 26)
    )
    allow(shown_lot).to receive(:lot_type).and_return(shown_lot_type)
    allow(shown_lot).to receive(:qcables).and_return([])

    MockApiV2.mock_lots_controller_search(lot_number, [found_lot])
    MockApiV2.mock_lots_controller_find_lot(shown_lot)

    visit root_path
    click_link 'View Lot'
    expect(page).to have_css('#findIDT.in')

    within('#findIDT form') do
      fill_in 'lot_number', with: lot_number
      click_button 'Find'
    end

    expect(page).to have_current_path("/lots/#{lot_uuid}", ignore_query: false)
    expect(page).to have_css('h1', text: 'Pre Stamped Tags: PST-12345')
    expect(page).to have_css('#lot_number', text: lot_number)
  end
end
