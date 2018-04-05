class Presenter::TagLayoutTemplate < Presenter::Template
  COMPATIBLE_WALKING_BY = ['wells of plate', 'quadrants'].freeze

  def grouped_templates
    compatible_templates.group_by do |template|
      template_is_suggested = (suggested_names == :all || suggested_names.include?(template.name))
      template_is_suggested ? 'Suggested Templates' : 'Other Templates'
    end
  end

  private

  def suggested_names
    Gatekeeper::Application.config.suggested_templates.tag_layout_template
  end

  def compatible_templates
    @api.tag_layout_template.all.select { |template| COMPATIBLE_WALKING_BY.include?(template.walking_by) }
  end

end
