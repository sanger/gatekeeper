# frozen_string_literal: true

class Presenter::Tag2LayoutTemplate < Presenter::Template
  def grouped_templates
    { 'All Templates': all_templates }
  end

  def all_templates
    @api.tag2_layout_template.all
  end
end
