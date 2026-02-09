# frozen_string_literal: true

##
# Include to provide barcode printing functionality to a controller
module BarcodePrinting
  def find_printer
    @printer = Sequencescape::Api::V2::BarcodePrinter.where(uuid: params[:barcode_printer]).first
  end
end
