# frozen_string_literal: true

require 'rails_helper'
require_relative 'lots_feature_shared'

RSpec.describe 'Lot search', type: :feature, js: true do
  include_context 'lots feature api stubs'

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
    allow(Sequencescape::Api::V2::Lot).to receive(:includes).with(:lot_type, :qcables)
                                                            .and_return(LotsFeatureTypes::LotScope.new([shown_lot]))
  end

  before do
    MockApiV1.mock_api_v1
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

  it 'shows an error when the lot number is not found' do
    not_found_lot_number = 'PST-not-found'
    allow(Sequencescape::Api::V2::Lot).to receive(:find).with(lot_number: not_found_lot_number).and_return([])

    visit new_lot_path(lot_type: 'Pre Stamped Tags')
    within('form.navbar-form') do
      find("input[name='lot_number']").set(not_found_lot_number)
      click_button 'Find'
    end

    expect(page).to have_current_path('/')
    expect(page).to have_css('.alert.alert-danger',
                             text: "Could not find a lot with the lot_number #{not_found_lot_number}")
  end
end
