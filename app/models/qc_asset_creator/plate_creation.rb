# frozen_string_literal: true

module QcAssetCreator::PlateCreation
  ##
  # Creates a plate of the specified purpose
  def asset_create
    api.plate_creation.create!(
      parent: @asset.uuid,
      child_purpose: @purpose,
      user: @user.uuid
    ).child
  end

  ##
  # Transfers the parent plate into the child plate
  def asset_transfer(child)
    transfer_template.create!(
      source: @asset.uuid,
      destination: child.uuid,
      user: @user.uuid
    )
  end

  def validate!
    return true if valid_children.include?(purpose)
    raise QcAssetCreator::QcAssetException, 'The type of plate or tube requested is not suitable'
  end

  def valid_children
    Settings.purposes[@asset.purpose.uuid].children
  end
end
