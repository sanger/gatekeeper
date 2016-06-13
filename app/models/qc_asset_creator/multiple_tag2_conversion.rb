##
# Converts one plate type (The target) to another
# and transfers the source in
module QcAssetCreator::MultipleTag2Conversion
  include PlateConversion

  ##
  # Ensures the qcable state changes are recorded
  def asset_update_state
    api.state_change.create!(
      :user => @user.uuid,
      :target => reporter_plate,
      :reason => 'Used in QC',
      :target_state => Gatekeeper::Application.config.qcing_state
    )
    api.state_change.create!(
      :user => @user.uuid,
      :target => tag_plate,
      :reason => 'Used to QC',
      :target_state => Gatekeeper::Application.config.used_state
    )
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

    each_tag2_template_with_tube_and_index do |tag2_template, tag2_tube, pos|
      #transfer_template_tube_to_well.create!(
      #  :source => tag2_tube,
      #  :destination => tag_plate,
      #  :user => @user.uuid,
      #  :column => pos
      #)

      api.tag2_layout_template.find(tag2_template).create!(
        :user => @user.uuid,
        :plate => tag_plate,
        :source => tag2_tube,
        :column => pos
      )
    end
  end

  def transfer_template_tube_to_well
    api.transfer_template.find('Transfer between specific tubes')
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

  def transfer_template_tube_to_well

  end

  def each_tag2_template_with_tube_and_index
    tag2_templates.zip(tag2_tubes_barcodes).each_with_index do |template, barcode, pos|
      yield template, api.tubes.find_by_barcode(barcode), pos
    end
  end

  def tag2_templates
    tag2_tubes_barcodes.map do |tag2_tube_barcode|
      api.search.find(Settings.searches['Find qcable by barcode']).first(:barcode => tag2_tube_barcode).lot.template.uuid
    end
  end

  def compatible_siblings?
    Settings.purposes[@sibling.purpose.uuid].sibling == @sibling2.purpose.name
  end

  ##
  # Raises QcAssetException if the asset is the wrong type, or is in the wrong state
  # We don't bother checking state if the type is wrong
  def validate!
    raise QcAssetCreator::QcAssetException, 'The type of plate or tube requested is not suitable.' unless valid_children.include?(purpose)
    errors = []
    errors << "The asset being QCed should be '#{Gatekeeper::Application.config.qcable_state}'." unless @sibling.qcable?
    errors << "The asset used to validate should be '#{Gatekeeper::Application.config.qced_state}'." unless @sibling2.qced?
    errors << "#{@sibling2.purpose.name} plates can't be used to test #{@sibling.purpose.name} plates." unless compatible_siblings?
    raise QcAssetCreator::QcAssetException, errors.join(' ') unless errors.empty?
    true
  end

end
