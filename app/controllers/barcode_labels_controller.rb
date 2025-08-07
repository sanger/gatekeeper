# frozen_string_literal: true

##
# Create event allows the printing of barcodes
class BarcodeLabelsController < ApplicationController
  include BarcodePrinting

  before_action :find_printer
  before_action :generate_labels

  def create
    BarcodeSheet.new(@printer, @labels).print!
    render(
      json: { 'success' => 'Your barcodes have been printed' }
    )
  rescue BarcodeSheet::PrintError => e
    Rails.logger.error(e.message)
    render(
      json: { 'error' => "There was a problem printing your barcodes. #{e.message}" }
    )
  rescue Errno::ECONNREFUSED
    render(
      json: { 'error' => 'Could not connect to the barcode printing service.' }
    )
  end

  private

  def generate_labels
    permitted_params = params.permit(:prefix, :study, numbers: {})
    @labels = (permitted_params[:numbers] || {}).to_h.map do |_, number|
      BarcodeSheet::Label.new(
        prefix: permitted_params[:prefix],
        number:,
        study: permitted_params[:study]
      )
    end
  end
end
