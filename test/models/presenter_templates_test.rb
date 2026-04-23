# frozen_string_literal: true

require 'test_helper'

class Presenter::TemplateTest < ActiveSupport::TestCase
  test '#grouped_templates' do
    api = mock('api')
    # Use a real subclass to test the logic
    presenter = Presenter::PlateTemplate.new(api)

    # Needs Settings.templates['plate_template']
    Settings.stubs(:templates).returns({ 'plate_template' => [{ 'name' => 'T1', 'uuid' => 'u1' }] })

    options = presenter.grouped_templates
    assert options.key?(:'Suggested Templates')
    assert_equal [{ 'name' => 'T1', 'uuid' => 'u1' }], options[:'Suggested Templates']
  end
end
