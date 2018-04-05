# frozen_string_literal: true

##
# Slightly different behaviour from PlateConversion that does not change the state of the asset
# and does not check that it is in qc state as QA plates could be in any state
module QcAssetCreator::QaPlateConversion
  include QcAssetCreator::PlateConversion

  ##
  # Ensures no update of the @asset state is performed
  # The @sibling still gets updated
  def asset_update_state
    api.state_change.create!(
      user: @user.uuid,
      target: @sibling.uuid,
      reason: 'Used to QC',
      target_state: Gatekeeper::Application.config.used_state
    )
  end

  ##
  # Raises QcAssetException if the asset is the wrong type
  def validate!
    errors = []
    errors << "The asset used to validate should be '#{Gatekeeper::Application.config.qced_state}'." unless @sibling.qced?
    errors << "#{@sibling.purpose.name} plates can't be used to test #{@asset.purpose.name} plates." unless compatible_siblings?
    raise QcAssetCreator::QcAssetException, errors.join(' ') unless errors.empty?
    true
  end
end
