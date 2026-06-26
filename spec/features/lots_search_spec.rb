# frozen_string_literal: true

require 'rails_helper'
require_relative 'lots_feature_shared'

RSpec.describe 'Lot search', type: :feature, js: true do
  include_context 'lots feature api stubs'

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
end
