##
# Designed to present information about lot types
# The relevant information should all be pretty static
# so we store the relevant information in the configuration
# on deployment.
class Presenter::LotType

  class ConfigurationError < StandardError; end

  attr_reader :name

  def initialize(lot_type_name)
    @name     = lot_type_name
    raise Presenter::LotType::ConfigurationError, "No lot type specified." if @name.nil?
    @settings = Settings.lot_types[lot_type_name]
    raise Presenter::LotType::ConfigurationError, "Unknown lot type '#{lot_type_name}'." if @settings.nil?
  end

  ##
  # A human formatted template name for labels etc.
  def template_type
    template_class.humanize
  end

  def uuid
    @settings.uuid
  end

  def each_template_option
    Settings.templates[template_class].each do |template|
      yield template.name, template.uuid
    end
  end

  private

  def template_class
    @settings.template_class.underscore
  end

end
