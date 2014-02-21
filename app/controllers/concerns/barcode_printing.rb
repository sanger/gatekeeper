##
# Include to provide barcode printing functionality to a controller
module BarcodePrinting

  def find_printer
    @printer = api.barcode_printer.find(params[:barcode_printer])
  end

end
