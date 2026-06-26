# frozen_string_literal: true

require 'rails_helper'
require_relative 'lots_feature_shared'

RSpec.describe 'Lot registration', type: :feature, js: true do
  include_context 'lots feature api stubs'

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