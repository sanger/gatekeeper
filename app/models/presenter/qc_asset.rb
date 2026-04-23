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
    direct_human_readable ||
      direct_human_barcode ||
      barcode_fallback ||
      ''
  end

  def direct_human_readable
    return unless @asset.respond_to?(:human_readable)

    @asset.human_readable
  end

  def direct_human_barcode
    return unless @asset.respond_to?(:human_barcode)

    @asset.human_barcode
  end

  def barcode_fallback
    return unless @asset.respond_to?(:barcode)

    barcode = @asset.barcode

    object_barcode(barcode) ||
      hash_barcode(barcode)
  end

  def object_barcode(barcode)
    return unless barcode.respond_to?(:prefix) && barcode.respond_to?(:number)

    "#{barcode.prefix}#{barcode.number}"
  end

  def hash_barcode(barcode)
    return unless barcode.is_a?(Hash)

    barcode = barcode.transform_keys(&:to_sym)

    prefix = barcode[:prefix]
    number = barcode[:number]
    return unless prefix || number

    "#{prefix}#{number}"
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
