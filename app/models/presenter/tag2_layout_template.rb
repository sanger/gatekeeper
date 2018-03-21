class Presenter::Tag2LayoutTemplate < Presenter::Template

  def templates
    all_templates = @api.tag2_layout_template.all
    {nil: all_templates}
  end

end
