# frozen_string_literal: true

module LotsFeatureTypes
  TemplateScope = Struct.new(:templates) do
    def all
      templates
    end
  end

  ApiStub = Struct.new(:tag_layout_template)

  LotScope = Struct.new(:lots) do
    def where(uuid:)
      lots.select { |lot| lot.uuid == uuid }
    end
  end
end

RSpec.shared_context 'lots feature api stubs' do
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
  let(:api) { LotsFeatureTypes::ApiStub.new(template_scope) }

  before do
    allow(Sequencescape::Api).to receive(:new).and_return(api)
  end
end
