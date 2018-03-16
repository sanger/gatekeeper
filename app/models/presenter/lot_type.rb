##
# Designed to present information about lot types
# The relevant information should all be pretty static
# so we store the relevant information in the configuration
# on deployment.
class Presenter::LotType

  class ConfigurationError < StandardError; end

  attr_reader :name

  def initialize(lot_type_name, templates)
    @name = lot_type_name
    raise Presenter::LotType::ConfigurationError, "No lot type specified." if @name.nil?
    @settings = Settings.lot_types[lot_type_name]
    raise Presenter::LotType::ConfigurationError, "Unknown lot type '#{lot_type_name}'." if @settings.nil?
    @templates = templates.select { |template| template.walking_by == 'wells of plate' }
    @suggested_templates, @other_templates = split_templates(@templates)
  end

  ##
  # A human formatted template name for labels etc.
  def template_type
    template_class.humanize
  end

  def uuid
    @settings.uuid
  end

  def suggested_template_options
    (@suggested_templates || no_template_options)
  end

  def other_template_options
    (@other_templates || no_template_options)
  end

  private

  NoTemplate = Struct.new(:name, :uuid)

  def split_templates(templates)
    suggested_templates = []
    other_templates = []
    suggested_names = Gatekeeper::Application.config.suggested_templates.tag_layout_template
    templates.each do |template|
      if (suggested_names == :all || suggested_names.include?(template.name))
        suggested_templates << template
      else
        other_templates << template
      end
    end
    [suggested_templates, other_templates]
  end

  def no_template_options
    [NoTemplate.new('No template available', nil)]
  end

  def template_class
    @settings.template_class.underscore
  end

end
