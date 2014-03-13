##
# Our plate creators work on behalf of the controllers
# They ensure we can composite the relevant behaviour based
# on the asset, without cluttering up the controller.
class QcAssetCreator

  class QcAssetException < StandardError; end

  module PlateCreation

    ##
    # Creates a plate of the specified purpose
    def plate_create
      api.plate_creation.create!(
        :parent => @asset.uuid,
        :child_purpose => @purpose,
        :user => @user.uuid
      ).child
    end

    ##
    # Transfers the parent plate into the child plate
    def plate_transfer(child)
      transfer_template.create!(
        :source => @asset.uuid,
        :destination => child.uuid,
        :user => @user.uuid
      )
    end

    def validate!
      return true if valid_children.include?(purpose)
      raise QcAssetException, 'The type of plate or tube requested is not suitable'
    end

    def valid_children
      Settings.purposes[@asset.purpose.uuid].children
    end

  end

  module PlateConversion

    ##
    # Actually converts the target plate to the specified purpose
    def plate_create
      api.plate_conversion.create!(
        :target => target,
        :purpose => @purpose,
        :user => @user.uuid,
      ).target
    end

    ##
    # Transfers the source plate into the target plate
    def plate_transfer(child)
      transfer_template.create!(
        :source => source,
        :destination => target,
        :user => @user.uuid
      )
    end

    ##
    # Raises QcAssetException if the asset is the wrong type, or is in the wrong state
    # We don't bother checking state if the type is wrong
    def validate!
      raise QcAssetException, 'The type of plate or tube requested is not suitable.' unless valid_children.include?(purpose)
      errors = []
      errors << "The asset being QCed should be '#{Gatekeeper::Application.config.qcable_state}'." unless @asset.qcable?
      errors << "The asset used to validate should be '#{Gatekeeper::Application.config.qced_state}'." unless @sibling.qced?
      raise QcAssetException, errors.join(' ') unless errors.empty?
      true
    end

    private

    def target
      asset_target ? @asset.uuid : @sibling.uuid
    end

    def source
      !asset_target ? @asset.uuid : @sibling.uuid
    end

    def target_purpose
      asset_target ? @asset.purpose.uuid : @sibling.purpose.uuid
    end

    def asset_target
      Settings.purposes[@asset.purpose.uuid].as == 'target'
    end

    def valid_children
      Settings.purposes[target_purpose].children
    end
  end

  module Completed
    def plate_create
      raise QcAssetException, "Children can't be created on the final asset in the pipeline."
    end
    def validate
      false
    end
  end


  attr_reader :api, :purpose, :sibling
  ##
  # Receives the parent asset, and composites itself
  def initialize(api:,asset:,user:,purpose:,sibling: nil)
    @api,@asset,@user,@purpose,@sibling = api,asset,user,purpose,sibling
    self.extend behaviour_module
  end

  def behaviour_module
    "QcAssetCreator::#{(Settings.purposes[@asset.purpose.uuid].with||'plate_creation').classify}".constantize
  end

  def transfer_template
    api.transfer_template.find(Settings.transfer_templates['Transfer columns 1-12'])
  end

  ##
  # Calls the appropriate api calls and returns the newly created asset
  def create!
    validate!
    plate_create.tap do |child|
      plate_transfer(child)
    end
  end

end
