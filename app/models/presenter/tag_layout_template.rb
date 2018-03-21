class Presenter::TagLayoutTemplate < Presenter::Template

  def templates
    suggested_names = Gatekeeper::Application.config.suggested_templates.tag_layout_template

    all_templates = @api.tag_layout_template.all.select { |template| template.walking_by == 'wells of plate' }
    all_templates.group_by do |template|
      template_is_suggested = (suggested_names == :all || suggested_names.include?(template.name))
      template_is_suggested ? 'Suggested Templates' : 'Other Templates'
    end
  end

end
