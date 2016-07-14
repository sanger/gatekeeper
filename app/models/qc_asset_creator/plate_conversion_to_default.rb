##
# Converts any given asset into @purpose without
# performing any validation.
module QcAssetCreator::PlateConversionToDefault

  include QcAssetCreator::PlateConversion

  def asset_update_state ; end
  def asset_transfer(_) ; end

  def validate!
    true
  end

  def target_asset
    @asset
  end

  ##
  # We only have one asset involved. In the event we
  # accidentally end up using source, its best
  # if we don't substitute in the target.
  def source_asset
    nil
  end

  ##
  # This is currently unused, but 'true' should ensure
  # correct behaviour in the event it ever gets called.
  def asset_target
    true
  end

end
