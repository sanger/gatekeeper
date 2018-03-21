class Presenter::TagLayoutTemplate

  def templates
    api = Sequencescape::Api.new(Gatekeeper::Application.config.api_connection_options)
    suggested_names = Gatekeeper::Application.config.suggested_templates.tag_layout_template

    all_templates = api.tag_layout_template.all.select { |template| template.walking_by == 'wells of plate' }
    grouped_templates = all_templates.group_by do |template|
      (suggested_names == :all || suggested_names.include?(template.name)) ? :suggested : :other
    end
    {suggested_templates: (grouped_templates[:suggested] || []),
     other_templates: (grouped_templates[:other] || [])}
  end

end
