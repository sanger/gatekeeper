##
# Designed to present information about lot types
# The relevant information should all be pretty static
# so we store the relevant information in the configuration
# on deployment.
class Presenter::LotType

  class ConfigurationError < StandardError; end

  attr_reader :name

  def initialize(lot_type_name, api)
    @name = lot_type_name
    @api = api
    raise Presenter::LotType::ConfigurationError, "No lot type specified." if @name.nil?
    @settings = Settings.lot_types[lot_type_name]
    raise Presenter::LotType::ConfigurationError, "Unknown lot type '#{lot_type_name}'." if @settings.nil?
  end

  ##
  # A human formatted template name for labels etc.
  def template_type
    @settings.template_class.underscore.humanize
  end

  def uuid
    @settings.uuid
  end

  def template_options
    grouped_templates = template_type_presenter.templates
    grouped_templates.each do |group_name, templates|
      grouped_templates[group_name] = [no_template_option] if templates.empty?
    end
  end

  private

  NoTemplate = Struct.new(:name, :uuid)

  def no_template_option
    NoTemplate.new('No template available', nil)
  end

  def template_type_presenter
    "Presenter::#{@settings.template_class}".constantize.new(@api)
  rescue NameError => exception
    raise Presenter::LotType::ConfigurationError, "#{exception}. Cannot instanciate template type presenter."
  end

end
