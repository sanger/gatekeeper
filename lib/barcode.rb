# frozen_string_literal: true

module Barcode
  def self.calculate_barcode(prefix, number)
    SBCF::SangerBarcode.from_prefix_and_number(prefix, number).machine_barcode
  end
end
