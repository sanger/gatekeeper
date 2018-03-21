class Presenter::Tag2LayoutTemplate < Presenter::Template

  def templates
    all_templates = @api.tag2_layout_template.all
    {'All Templates': all_templates}
  end

end
