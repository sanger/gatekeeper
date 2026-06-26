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

RSpec.describe 'Lot registration pages', type: :feature do
  before do
    allow(Sequencescape::Api).to receive(:new).and_return(api)
  end

  let(:user) { Sequencescape::Api::V2::User.new(uuid: '11111111-2222-3333-4444-555555555555') }
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

  it 'renders the new page for Pre Stamped Tags' do
    visit new_lot_path(lot_type: 'Pre Stamped Tags')

    expect(page).to have_current_path('/lots/new?lot_type=Pre+Stamped+Tags', ignore_query: false)
    expect(page).to have_css('h1', text: 'Register Pre Stamped Tags Lot')
    expect(page).to have_selector("input#lot_type_uuid[value='0eb10418-ff2e-11ef-99ca-060cfcc4e0a0']", visible: false)
    expect(page).to have_selector("input#template_class[value='TagLayoutTemplate']", visible: false)
    expect(page).to have_field('Lot number')
    expect(page).to have_field('Tag layout template')
    expect(page).to have_select('template', with_options: ['Example Tag Template', 'Another Tag Layout'])
  end

  it 'renders the new page for Pre Stamped Tags - 384' do
    visit new_lot_path(lot_type: 'Pre Stamped Tags - 384')

    expect(page).to have_current_path('/lots/new?lot_type=Pre+Stamped+Tags+-+384', ignore_query: false)
    expect(page).to have_css('h1', text: 'Register Pre Stamped Tags - 384 Lot')
    expect(page).to have_selector("input#lot_type_uuid[value='0eb27564-ff2e-11ef-99ca-060cfcc4e0a0']", visible: false)
    expect(page).to have_selector("input#template_class[value='TagLayoutTemplate']", visible: false)
    expect(page).to have_field('Lot number')
    expect(page).to have_field('Tag layout template')
    expect(page).to have_select('template', with_options: ['Example Tag Template', 'Another Tag Layout'])
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
