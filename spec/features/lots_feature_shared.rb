# frozen_string_literal: true

module LotsFeatureTypes
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
end

RSpec.shared_context 'lots feature api stubs' do
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

  let(:template_scope) { LotsFeatureTypes::TemplateScope.new(tag_templates) }
  let(:user_search_scope) { LotsFeatureTypes::UserSearchScope.new(user) }
  let(:search_scope) { LotsFeatureTypes::SearchScope.new(user_search_scope) }
  let(:api) { LotsFeatureTypes::ApiStub.new(search_scope, template_scope) }

  before do
    allow(Sequencescape::Api).to receive(:new).and_return(api)
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

    allow(Sequencescape::Api::V2::Lot).to receive(:includes).with(:lot_type, :qcables).and_return(LotsFeatureTypes::LotScope.new([shown_lot]))
  end

  def stub_lot_search_and_show(found_lot_uuid:, found_lot_number:, lot_type_name:)
    found_lot = Sequencescape::Api::V2::Lot.new(uuid: found_lot_uuid)
    shown_lot = build_shown_lot(
      lot_uuid: found_lot_uuid,
      lot_number: found_lot_number,
      lot_type_name:,
      qcables: []
    )

    allow(Sequencescape::Api::V2::Lot).to receive(:find).with(lot_number: found_lot_number).and_return([found_lot])
    allow(Sequencescape::Api::V2::Lot).to receive(:includes).with(:lot_type, :qcables).and_return(LotsFeatureTypes::LotScope.new([shown_lot]))
  end

  def build_shown_lot(lot_uuid:, lot_number:, lot_type_name:, qcables: [])
    shown_lot_type = Sequencescape::Api::V2::LotType.new(
      qcable_name: 'Pre Stamped Tag Plate',
      printer_type: '96 Well Plate'
    )
    shown_lot = Sequencescape::Api::V2::Lot.new(
      uuid: lot_uuid,
      lot_number:,
      lot_type_name:,
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
    allow(Sequencescape::Api::V2::Lot).to receive(:includes).with(:lot_type, :qcables).and_return(LotsFeatureTypes::LotScope.new([shown_lot]))
    shown_lot
  end
end