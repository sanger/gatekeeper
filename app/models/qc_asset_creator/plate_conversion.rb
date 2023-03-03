# frozen_string_literal: true

##
# Converts one plate type (The target) to another
# and transfers the source in
module QcAssetCreator::PlateConversion
  ##
  # Ensures the qcable state changes are recorded
  def asset_update_state
    api.state_change.create!(
      user: @user.uuid,
      target: @asset.uuid,
      reason: 'Used in QC',
      target_state: Gatekeeper::Application.config.qcing_state
    )
    api.state_change.create!(
      user: @user.uuid,
      target: @sibling.uuid,
      reason: 'Used to QC',
      target_state: Gatekeeper::Application.config.used_state
    )
  end

  ##
  # Actually converts the target plate to the specified purpose
  def asset_create
    api.plate_conversion.create!(
      target:,
      purpose: @purpose,
      user: @user.uuid
    ).target
  end

  ##
  # Transfers the source plate into the target plate
  # The child is ignored (Although it should be the same as the target plate)
  # Applies tags
  def asset_transfer(_)
    transfer_template.create!(
      source:,
      destination: target,
      user: @user.uuid
    )
    api.tag_layout_template.find(tag_template).create!(
      user: @user.uuid,
      plate: target,
      substitutions: {}
    )
  end

  ##
  # Raises QcAssetException if the asset is the wrong type, or is in the wrong state
  def validate!
    errors = []
    errors << "The asset being QCed should be '#{Gatekeeper::Application.config.qcable_state}'." unless @asset.qcable?
    errors << "The #{expected_sibling} asset used to validate should be '#{Gatekeeper::Application.config.qced_state}'." unless @sibling.qced?
    errors << "#{@sibling.purpose.name} plates can't be used to test #{@asset.purpose.name} plates, please use a #{expected_sibling}." unless compatible_siblings?
    errors << 'The type of plate or tube requested is not suitable.' unless errors.present? || valid_children.include?(purpose)
    raise QcAssetCreator::QcAssetException, errors.join(' ') unless errors.empty?
    true
  end

  private

  # Returns true if the config indicates that @asset is a 'target'
  # targets receive material from sources
  def asset_target
    Settings.purposes.has_key?(@asset.purpose.uuid) && Settings.purposes[@asset.purpose.uuid].as == 'target'
  end

  # Returns the target asset for the conversion
  def target_asset
    asset_target ? @asset : @sibling
  end

  # Returns the source asset for the conversion
  def source_asset
    asset_target ? @sibling : @asset
  end

  def target
    target_asset.uuid
  end

  def source
    source_asset.uuid
  end

  def target_purpose
    target_asset.purpose.uuid
  end

  def valid_children
    Settings.purposes[target_purpose].children
  end

  def compatible_siblings?
    expected_sibling == @sibling.purpose.name
  end

  def expected_sibling
    Settings.purposes[@asset.purpose.uuid].sibling
  end

  def target_barcode
    target_asset.barcode.ean13
  end

  def tag_template
    api.search.find(Settings.searches['Find qcable by barcode']).first(barcode: target_barcode).lot.template.uuid
  end
end
