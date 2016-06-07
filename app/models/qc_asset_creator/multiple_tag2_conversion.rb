##
# Converts one plate type (The target) to another
# and transfers the source in
module QcAssetCreator::MultipleTag2Conversion
  include PlateConversion

  def asset_update_state
  end

  ##
  # Transfers the source plate into the target plate
  # The child is ignored (Although it should be the same as the target plate)
  def asset_transfer(_)
    transfer_template.create!(
      :source => reporter_plate,
      :destination => tag_plate,
      :user => @user.uuid
    )
    api.tag_layout_template.find(tag_template).create!(
      :user => @user.uuid,
      :plate => tag_plate,
      :substitutions => {}
    )

    tag2_templates.each_with_index do |tag2_template, pos|
      api.tag2_layout_template.find(tag2_template).create!(
        :user => @user.uuid,
        :plate => tag_plate,
        :column => pos
      )
    end
  end

  ##
  # Actually converts the target plate to the specified purpose
  def asset_create
    api.plate_conversion.create!(
      :target => tag_plate,
      :purpose => @purpose,
      :user => @user.uuid,
    ).target
  end

  def reporter_plate
    target
  end

  def tag_plate
    sibling2.uuid
  end

  def tube
    source
  end

  def tag2_templates
    tag2_tubes_barcodes.map do |tag2_tube_barcode|
      api.search.find(Settings.searches['Find qcable by barcode']).first(:barcode => tag2_tube_barcode).lot.template.uuid
    end
  end

  ##
  # Raises QcAssetException if the asset is the wrong type, or is in the wrong state
  # We don't bother checking state if the type is wrong
  def validate!
    raise QcAssetCreator::QcAssetException, 'The type of plate or tube requested is not suitable.' unless valid_children.include?(purpose)
    errors = []
    # TODO: Add them back
    #errors << "The asset being QCed should be '#{Gatekeeper::Application.config.qcable_state}'." unless @asset.qcable?
    #errors << "The asset used to validate should be '#{Gatekeeper::Application.config.qced_state}'." unless @sibling.qced?
    errors << "#{@sibling.purpose.name} plates can't be used to test #{@asset.purpose.name} plates." unless compatible_siblings?
    raise QcAssetCreator::QcAssetException, errors.join(' ') unless errors.empty?
    true
  end

end
