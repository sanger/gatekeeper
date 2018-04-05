module QcAssetCreator::TubeCreation

    ##
    # Creates a tube of the specified purpose
    def asset_create
      api.specific_tube_creation.create!(
        user: @user.uuid,
        parent: @asset.uuid,
        child_purposes: [@purpose]
      ).children.first
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

    def default_template
      Settings.transfer_templates['Whole plate to tube']
    end

    def validate!
      return true if valid_children.include?(purpose)
      raise QcAssetCreator::QcAssetException, 'The type of plate or tube requested is not suitable'
    end

    def valid_children
      Settings.purposes[@asset.purpose.uuid].children
    end

end
