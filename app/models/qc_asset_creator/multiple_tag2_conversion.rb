##
# Converts one plate type (The target) to another and transfers the source in
# Assumes that @sibling is the target and @sibling2 the source
# Then applies the secondary as a tag 2
require_relative 'plate_conversion'
module QcAssetCreator::MultipleTag2Conversion
  include QcAssetCreator::PlateConversion

  ##
  # Ensures the qcable state changes are recorded
  def asset_update_state
    api.state_change.create!(
      :user => @user.uuid,
      :target => target,
      :reason => 'Used to QC',
      :target_state => Gatekeeper::Application.config.used_state
    )
    api.state_change.create!(
      :user => @user.uuid,
      :target => source,
      :reason => 'Used to QC',
      :target_state => Gatekeeper::Application.config.used_state
    )
  end

  ##
  # Transfers the source plate into the target plate
  # The child is ignored (Although it should be the same as the target plate)
  # Applies tags
  # Applies tag2s
  def asset_transfer(_)

    super

    each_tag2_template_with_tube_and_locations do |tag2_template, tag2_tube, target_well_locations|
      api.tag2_layout_template.find(tag2_template).create!(
        :user => @user.uuid,
        :plate => target,
        :source => tag2_tube,
        :target_well_locations => target_well_locations
      )
    end
  end

  ##
  # Raises QcAssetException if the asset is the wrong type, or is in the wrong state
  def validate!
    errors = []
    errors << "The #{expected_sibling} asset used to validate should be '#{Gatekeeper::Application.config.qced_state}'." unless @sibling.qced?
    errors << "The #{expected_sibling2} asset used to validate should be '#{Gatekeeper::Application.config.qced_state}'." unless @sibling2.qced?
    errors << "#{@sibling.purpose.name} plates can't be used to test #{@asset.purpose.name} plates, please use a #{expected_sibling}." unless compatible_siblings?
    errors << "#{@sibling2.purpose.name} plates can't be used to test #{@asset.purpose.name} plates, please use a #{expected_sibling2}." unless compatible_sibling2s?
    errors << 'The type of plate or tube requested is not suitable.' unless errors.present? || valid_children.include?(purpose)
    errors << "Could not find #{missing_tag2_qcables.to_sentence}." unless missing_tag2_qcables.empty?
    errors << "All #{@asset.purpose.name} should be '#{Gatekeeper::Application.config.qcable_state}'" unless all_tag2s_qcable?
    raise QcAssetCreator::QcAssetException, errors.join(' ') unless errors.empty?
    true
  end

  private

  def target_asset
    @sibling
  end

  def source_asset
    @sibling2
  end

  def compatible_sibling2s?
    expected_sibling2 == @sibling2.purpose.name
  end

  def expected_sibling2
    Settings.purposes[@asset.purpose.uuid].sibling2
  end

  def tag2_qcables
    return @tag2_qcables ||= api.search.find(Settings.searches['Find qcable by barcode']).
      all(Gatekeeper::Qcable,:barcode => tag2_tubes_barcodes.values).
      inject({}) do |hash,qcable|
        hash[qcable.barcode.ean13] = qcable
        hash
      end
  end

  def each_tag2_template_with_tube_and_locations
    tag2_tubes_barcodes.each do |index, barcode|
      qcable = tag2_qcables[barcode]
      yield qcable.lot.template.uuid, qcable.asset.uuid, tag2_locations_for_barcode(barcode)
    end
  end

  def all_tag2s_qcable?
    tag2_qcables.all?{|barcode,qcable| qcable.qcable? }
  end

  def missing_tag2_qcables
    tag2_tubes_barcodes.values - tag2_qcables.keys
  end


end
