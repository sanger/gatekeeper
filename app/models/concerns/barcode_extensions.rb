# frozen_string_literal: true

module BarcodeExtensions
  def human_barcode
    "#{barcode.prefix}#{barcode.number}"
  end
  alias human_readable human_barcode
end
