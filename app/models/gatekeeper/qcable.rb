# frozen_string_literal: true

##
# Namespcaced Qcable as per:
# https://github.com/sanger/sequencescape-client-api/wiki/Extending-the-Ruby-client-library
# Provides useful methods to move behaviour out of the controllers

class Gatekeeper::Qcable < Sequencescape::Qcable
  include BarcodeExtensions
  include StateExtensions

  def in_lot?(lot)
    self.lot.uuid == lot.uuid
  end

  attribute_group :barcode do
    attribute_accessor :prefix, :number     # The pieces that make up a barcode
    attribute_accessor :ean13               # The EAN13 barcode number
    attribute_accessor :machine             # The EAN13 barcode number
  end

  def machine_barcode
    barcode.machine
  end
end
