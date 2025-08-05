# frozen_string_literal: true

##
# Include to provide barcode printing functionality to a controller
module BarcodePrinting
  def find_printer
    @printer = api.barcode_printer.find(params[:barcode_printer])
  end

  def find_printer_v2
    @printer_v2 = Sequencescape::Api::V2::BarcodePrinter.where(uuid: params[:barcode_printer]).first
  end
end
