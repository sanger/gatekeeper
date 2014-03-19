##
# Our plate creators work on behalf of the controllers
# They ensure we can composite the relevant behaviour based
# on the asset, without cluttering up the controller.
class QcAssetCreator

  class QcAssetException < StandardError; end

  attr_reader :api, :purpose, :sibling
  ##
  # Receives the parent asset, and composites itself
  def initialize(api:,asset:,user:,purpose:,sibling: nil,template: nil)
    @api,@asset,@user,@purpose,@sibling,@template = api,asset,user,purpose,sibling,template
    self.extend behaviour_module
  end

  ##
  # Calls the appropriate api calls and returns the newly created asset
  def create!
    validate!
    asset_update_state
    asset_create.tap do |child|
      asset_transfer(child)
    end
  end

  def asset_update_state
    # Nothing to do here
  end

  def asset_create
    raise StandardError, 'Create not yet implemented for this asset!'
  end

  def asset_transfer
    raise StandardError, 'Transfer not yet implemented for this asset!'
  end

  private

  ##
  # Determines which module to extend with
  def behaviour_module
    "QcAssetCreator::#{(Settings.purposes[@asset.purpose.uuid].with||'plate_creation').classify}".constantize
  end

  ##
  # Determines which transfer template to use
  def transfer_template
    api.transfer_template.find(@template||default_template)
  end

  def default_template
    Settings.transfer_templates['Transfer columns 1-12']
  end

end
