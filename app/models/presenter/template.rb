class Presenter::Template

  def templates
    template_class_last_name = self.class.name.split('::').last.underscore
    {nil: Settings.templates[template_class_last_name]}
  end

end

