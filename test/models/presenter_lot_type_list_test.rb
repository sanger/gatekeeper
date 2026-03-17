# frozen_string_literal: true

require 'test_helper'
require 'mock_api'

class Presenter::LotTypeTest < ActiveSupport::TestCase
  include MockApi

  setup do
    mock_api
  end

  test 'initialise with IDT Tags' do
    presenter = Presenter::LotType.new('IDT Tags', api)
    assert_equal 'IDT Tags', presenter.name
    assert_equal 'TagLayoutTemplate', presenter.template_class
    assert_equal 'Tag layout template', presenter.template_type
  end

  test 'initialise with unknown lot type' do
    assert_raises(Presenter::LotType::ConfigurationError) do
      Presenter::LotType.new('Unknown', api)
    end
  end

  test 'initialise with nil lot type' do
    assert_raises(Presenter::LotType::ConfigurationError) do
      Presenter::LotType.new(nil, api)
    end
  end

  test '#template_options' do
    # Mocking suggested_templates config usually found in initializers
    Gatekeeper::Application.config.stubs(:suggested_templates).returns(
      Hashie::Mash.new(tag_layout_template: :all)
    )

    # Mocking api response for tag_layout_template
    t1 = mock('template1')
    t1.stubs(:name).returns('T1')
    t1.stubs(:uuid).returns('uuid1')
    t1.stubs(:walking_by).returns('wells of plate')

    api.tag_layout_template.stubs(:all).returns([t1])

    presenter = Presenter::LotType.new('IDT Tags', api)
    options = presenter.template_options

    assert options.key?('Suggested Templates')
    assert_equal [%w[T1 uuid1]], options['Suggested Templates']
  end
end
