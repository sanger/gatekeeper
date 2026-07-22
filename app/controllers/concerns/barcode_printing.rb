# frozen_string_literal: true

##
# Include to provide barcode printing functionality to a controller
module BarcodePrinting
  def find_printer
    @printer = Sequencescape::Api::V2::BarcodePrinter.where(uuid: printer_uuid).first
  end

  private

  def printer_uuid
    permitted_params[:barcode_printer]
  end

  def permitted_params
    params.require(:barcode_printer)
  end
end
