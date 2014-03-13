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
    Hash[Settings.purposes[@asset.purpose.uuid].children.map {|uuid| [Settings.purposes[uuid].name,uuid]}]
  end

  def purpose
    Settings.purposes[@asset.purpose.uuid].name
  end

  def children
    @asset.children
  end

  def barcode
    @asset.barcode
  end

  def handler
    {
      'with' => Settings.purposes[@asset.purpose.uuid].with||'plate_creation',
      'as'   => Settings.purposes[@asset.purpose.uuid].as||''
    }
  end

  ##
  # Used to define the json returned by the presenter
  def output
    { 'qc_asset' => {
        'purpose' => purpose,
        'barcode' => @asset.barcode,
        'child_purposes' => child_purposes,
        'state' => state,
        'children' => children.map {|c| c.uuid},
        'handle' => handler
      }
    }
  end


end
