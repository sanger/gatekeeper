# frozen_string_literal: true

class Presenter::Tag2LayoutTemplateTest < ActiveSupport::TestCase
  test '#grouped_templates' do
    api = mock('api')
    t1 = mock('t1')
    api.stubs(:tag2_layout_template).returns(mock('resource'))
    api.tag2_layout_template.stubs(:all).returns([t1])

    presenter = Presenter::Tag2LayoutTemplate.new(api)
    assert_equal({ 'All Templates': [t1] }, presenter.grouped_templates)
  end
end
