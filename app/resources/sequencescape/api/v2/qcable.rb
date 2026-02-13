# frozen_string_literal: true

# Represents a Qcable using the Sequencescape V2 API
class Sequencescape::Api::V2::Qcable < Sequencescape::Api::V2::Base
  has_one :qcable_creator

  # Simple value object to provide V1-compatible .prefix and .number accessors
  BarcodeWrapper = Struct.new(:prefix, :number)

  # Provides a V1-compatible barcode interface wrapping the V2 labware_barcode hash.
  # The V2 API returns labware_barcode as { 'human_barcode' => 'DN1S', ... } whereas
  # the V1 API returned barcode as an object with .prefix and .number accessors.
  # This method bridges the gap so that Presenter::Qcable (and Presenter::Lot#prefix)
  # continue to work without change.
  def barcode
    @barcode ||= BarcodeWrapper.new(*extract_prefix_and_number)
  end

  private

  def extract_prefix_and_number
    human = human_barcode_string
    prefix = human[/\A([A-Za-z]+)/, 1] || ''
    number = human[/[A-Za-z]+(\d+)/, 1] || ''
    [prefix, number]
  end

  def human_barcode_string
    lb = labware_barcode
    return '' unless lb.is_a?(Hash)

    (lb['human_barcode'] || lb[:human_barcode]).to_s
  end
end
