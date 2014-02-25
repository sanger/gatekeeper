module BarcodeExtensions
  def human_barcode
    "#{barcode.prefix}#{barcode.number}"
  end
end
