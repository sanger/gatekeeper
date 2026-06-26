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
end
