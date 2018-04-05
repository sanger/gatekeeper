# frozen_string_literal: true

class Presenter::Template
  def initialize(api)
    @api = api
  end

  def grouped_templates
    template_class_last_name = self.class.name.split('::').last.underscore
    { 'Suggested Templates': Settings.templates[template_class_last_name] }
  end
end
