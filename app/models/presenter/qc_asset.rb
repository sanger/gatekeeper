##
# Presents assets in json fomat to the
# QC pipeline.
class Presenter::QcAsset

  class DefaultPurpose
    attr_reader :uuid, :children, :with, :as, :name, :sibling, :printer, :type
    def initialize(default_purpose)
      @uuid       = default_purpose[:uuid]
      @name       = default_purpose[:name]
      @with       = default_purpose[:with]
      @as         = default_purpose[:as]
      @type       = default_purpose[:type]
      @children   = [uuid].compact
    end
  end

  attr_reader :asset

  def initialize(record)
    @asset = record
  end

  delegate :uuid, :state, to: :asset

  def child_purposes
    (own_child_purpose||sibling_child_purpose).map {|uuid| [purpose_config_of_uuid(uuid).name,uuid]}
  end

  def purpose
    @asset.purpose.name
  end

  def children
    @asset.children
  end

  def child_type
    (own_child_purpose||sibling_child_purpose).map do |uuid|
      purpose_config_of_uuid(uuid).type.pluralize
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
      'with'    => own_purpose_config.with||'plate_creation',
      'as'      => own_purpose_config.as||'',
      'sibling' => own_purpose_config.sibling||'',
      'printer' => own_purpose_config.printer||'plate'
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

  def own_purpose_config
    purpose_config_of_uuid(@asset.purpose.uuid)
  end

  def purpose_config_of_uuid(uuid)
    Settings.purposes[uuid] || DefaultPurpose.new(Settings.default_purpose)
  end

  ##
  # I guess that makes this niece/nephew purpose
  def sibling_child_purpose
    return Settings.purposes.detect {|k,v| v.name == own_purpose_config.sibling }.last.children
  end

  def own_child_purpose
    return nil unless own_purpose_config.as == 'target'
    own_purpose_config.children
  end



end
