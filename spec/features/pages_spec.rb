# frozen_string_literal: true

require 'rails_helper'

PagesApiStub = Struct.new

PagesLotScope = Struct.new(:lots) do
  def where(uuid:)
    lots.select { |current_lot| current_lot.uuid == uuid }
  end
end

RSpec.describe 'Pages', type: :feature do
  let(:api) { PagesApiStub.new }

  before do
    allow(Sequencescape::Api).to receive(:new).and_return(api)
  end

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
      lot_number: 'PST-12345',
      lot_type_name: 'Pre Stamped Tags',
      template_name: 'Example Tag Template',
      received_at: Date.new(2026, 6, 26)
    )
    allow(shown_lot).to receive(:lot_type).and_return(shown_lot_type)
    allow(shown_lot).to receive(:qcables).and_return([])

    allow(Sequencescape::Api::V2::Lot).to receive(:find).with(lot_number: 'PST-12345').and_return([found_lot])
    allow(Sequencescape::Api::V2::Lot).to receive(:includes).with(:lot_type,
                                                                  :qcables).and_return(PagesLotScope.new([shown_lot]))

    visit root_path
    click_link 'View Lot'
    expect(page).to have_css('#findIDT.in')

    within('#findIDT form') do
      fill_in 'lot_number', with: 'PST-12345'
      click_button 'Find'
    end

    expect(page).to have_current_path("/lots/#{lot_uuid}", ignore_query: false)
    expect(page).to have_css('h1', text: 'Pre Stamped Tags: PST-12345')
    expect(page).to have_css('#lot_number', text: 'PST-12345')
  end
end
