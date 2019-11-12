# frozen_string_literal: true

##
# Designed to present information about lot types
# The relevant information should all be pretty static
# so we store the relevant information in the configuration
# on deployment.
class Presenter::LotType
  class ConfigurationError < StandardError; end

  attr_reader :name, :settings

  delegate :uuid, :template_class, to: :settings
  delegate :grouped_templates, to: :template_type_presenter

  def initialize(lot_type_name, api)
    @name = lot_type_name
    @api = api
    raise Presenter::LotType::ConfigurationError, 'No lot type specified.' if @name.nil?
    @settings = Settings.lot_types[lot_type_name]
    raise Presenter::LotType::ConfigurationError, "Unknown lot type '#{lot_type_name}'." if @settings.nil?
  end

  ##
  # A human formatted template name for labels etc.
  def template_type
    template_class.underscore.humanize
  end

  def template_options
    grouped_templates = template_type_presenter.grouped_templates
    grouped_templates.each do |group_name, templates|
      options = templates.map { |template| [template.name, template.uuid] }
      grouped_templates[group_name] = options
    end
  end

  private

  def template_type_presenter
    @template_type_presenter ||= "Presenter::#{template_class}".constantize.new(@api)
  rescue NameError => e
    raise Presenter::LotType::ConfigurationError, "#{e}. Unrecognised template class '#{template_class}'."
  end
end
