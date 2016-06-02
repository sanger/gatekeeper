##
# Slightly different behaviour from PlateConversion that does not change the state of the asset
# and does not check that it is in qc state as QA plates could be in any state
module QcAssetCreator::PlateConversionToDefault

  include QcAssetCreator::PlateConversion

  def asset_update_state ; end
  def asset_transfer(_) ; end
  def validate! ; end


  def target
    @asset.uuid
  end

  def source
    @asset.uuid
  end

  def asset_target
    true
  end

end
