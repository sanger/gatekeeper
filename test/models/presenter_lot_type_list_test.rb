# frozen_string_literal: true

require 'test_helper'

class Presenter::LotTypeTest < ActiveSupport::TestCase
  test 'initialise with IDT Tags' do
    presenter = Presenter::LotType.new('IDT Tags')
    assert_equal 'IDT Tags', presenter.name
    assert_equal 'TagLayoutTemplate', presenter.template_class
    assert_equal 'Tag layout template', presenter.template_type
  end

  test 'initialise with unknown lot type' do
    assert_raises(Presenter::LotType::ConfigurationError) do
      Presenter::LotType.new('Unknown')
    end
  end

  test 'initialise with nil lot type' do
    assert_raises(Presenter::LotType::ConfigurationError) do
      Presenter::LotType.new(nil)
    end
  end

  test '#template_options' do
    # Mocking suggested_templates config usually found in initializers
    Gatekeeper::Application.config.stubs(:suggested_templates).returns(
      Hashie::Mash.new(tag_layout_template: :all)
    )

    mock_tag_layout_template = Sequencescape::Api::V2::TagLayoutTemplate.new(
      name: 'T1',
      uuid: 'uuid1',
      walking_by: 'wells of plate'
    )
    Sequencescape::Api::V2::TagLayoutTemplate.stubs(:all).returns([mock_tag_layout_template])

    presenter = Presenter::LotType.new('IDT Tags')
    options = presenter.template_options

    assert options.key?('Suggested Templates')
    assert_equal [%w[T1 uuid1]], options['Suggested Templates']
  end
end
