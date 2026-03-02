# frozen_string_literal: true

##
# Presents assets in json fomat to the
# QC pipeline.
class Presenter::QcAsset
  attr_reader :asset

  def initialize(record)
    @asset = record
  end

  delegate :uuid, :state, to: :asset

  def child_purposes
    (own_child_purpose || sibling_child_purpose).map { |uuid| [purpose_config_of_uuid(uuid).name, uuid] }
  end

  def purpose
    @asset.purpose.name
  end

  delegate :children, to: :@asset

  def child_type
    (own_child_purpose || sibling_child_purpose).map do |uuid|
      purpose_config_of_uuid(uuid).type.pluralize
    end.first || 'unknown'
  end

  def barcode
    {
      'ean13' => @asset.barcode.ean13,
      'human_readable' => human_readable
    }
  end

  def handler
    {
      'with' => own_purpose_config.with || 'plate_creation',
      'as' => own_purpose_config.as || '',
      'sibling' => own_purpose_config.sibling || '',
      'printer' => own_purpose_config.printer || 'plate'
    }.tap do |handle|
      handle['sibling2'] = own_purpose_config.sibling2 if own_purpose_config.sibling2
    end
  end

  ##
  # Used to define the json returned by the presenter
  def output
    { 'qc_asset' => {
      'uuid' => uuid,
      'purpose' => purpose,
      'barcode' => barcode,
      'child_purposes' => child_purposes,
      'state' => state,
      'children' => children.map { |c| [child_type, c.uuid] },
      'handle' => handler
    } }
  end

  def human_readable
    return @asset.human_readable if @asset.respond_to?(:human_readable)
    return @asset.human_barcode if @asset.respond_to?(:human_barcode)

    # Fallback for mock objects that only have the barcode hash
    bc = @asset.barcode
    if bc.respond_to?(:prefix) && bc.respond_to?(:number)
      "#{bc.prefix}#{bc.number}"
    elsif bc.is_a?(Hash)
      "#{bc['prefix'] || bc[:prefix]}#{bc['number'] || bc[:number]}"
    else
      ''
    end
  end

  private

  def own_purpose_config
    purpose_config_of_uuid(@asset.purpose.uuid)
  end

  def purpose_config_of_uuid(uuid)
    Settings.purposes[uuid] || Settings.default_purpose
  end

  ##
  # I guess that makes this niece/nephew purpose
  def sibling_child_purpose
    Settings.purposes.detect { |k, v| v.name == own_purpose_config.sibling }.last.children
  end

  def own_child_purpose
    return nil if %w[source secondary].include?(own_purpose_config.as)

    own_purpose_config.children
  end
end
