# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages', type: :feature do
  before do
    allow(Sequencescape::Api).to receive(:new).and_return(double('Sequencescape::Api'))
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
end
