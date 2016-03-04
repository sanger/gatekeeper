##
# Presents assets in json fomat to the
# QC pipeline.

class Presenter::QcAsset

  class DefaultPurpose
    def initialize(purpose)
      @purpose = purpose
    end
    def uuid ; Settings.default_purpose.uuid ; end
    def children; [Settings.default_purpose.uuid]; end
    def with; Settings.default_purpose.with; end
    def as; Settings.default_purpose.as ; end
    def convert_to ; Settings.default_purpose.convert_to ; end
    def sibling; end
    def printer; end
  end

  attr_reader :asset

  def initialize(record)
    @asset = record
  end

  delegate :uuid, :state, to: :asset

  def child_purposes
    if is_default_purpose?
      return [[purpose_config.convert_to, purpose_config.uuid]]
    end
    (own_child_purpose||sibling_child_purpose).map {|uuid| [Settings.purposes[uuid].name,uuid]}
  end

  def purpose
    @asset.purpose.name
  end

  def is_default_purpose?
    purpose_config.is_a?(DefaultPurpose)
  end

  def children
    @asset.children
  end

  def child_type
    (own_child_purpose||sibling_child_purpose).map do |uuid|
      Settings.purposes[uuid].type.pluralize
    end.first||'unknown'
  end

  def barcode
    {
      'ean13' => @asset.barcode.ean13,
      'prefix' => @asset.barcode.prefix,
      'number' => @asset.barcode.number
    }
  end

  def handler
    {
      'with'    => purpose_config.with||'plate_creation',
      'as'      => purpose_config.as||'',
      'sibling' => purpose_config.sibling||'',
      'printer' => purpose_config.printer||'plate'
    }
  end

  ##
  # Used to define the json returned by the presenter
  def output
    { 'qc_asset' => {
        'uuid'           => uuid,
        'purpose'        => purpose,
        'barcode'        => barcode,
        'child_purposes' => child_purposes,
        'state'          => state,
        'children'       => children.map {|c| [child_type,c.uuid] },
        'handle'         => handler
      }
    }
  end

  private

  def purpose_config
    Settings.purposes[@asset.purpose.uuid] || DefaultPurpose.new(@asset.purpose)
  end

  ##
  # I guess that makes this niece/nephew purpose
  def sibling_child_purpose
    return [] if is_default_purpose?
    return Settings.purposes.detect {|k,v| v.name == purpose_config.sibling }.last.children
  end

  def own_child_purpose
    return nil if purpose_config.as == 'source'
    purpose_config.children
  end



end
