##
# Controls the making and destroying of qcables
class QcablesController < ApplicationController

  include BarcodePrinting

  before_filter :find_user, :find_printer, :find_lot, :validate_plate_count

  ##
  # This action should generally get called through the nested
  # lot/qcables route, which will provide our lot id.
  def create

    qc_creator = api.qcable_creator.create!(
      :user => @user.uuid,
      :lot  => @lot.uuid,
      :count => params[:plate_number].to_i
    )

    labels = qc_creator.qcables.map do |q|
      Sanger::Barcode::Printing::Label.new(:prefix=>q.barcode.prefix,:number=>q.barcode.number,:study=>"#{@lot.lot_number}:#{@lot.template_name}")
    end

    begin
      BarcodeSheet.new(@printer,labels).print!
    rescue BarcodeSheet::PrintError => exception
      flash[:danger] = "There was a problem printing your barcodes. Your plates have still been created."
    rescue Errno::ECONNREFUSED => exception
      flash[:danger] = "Could not connect to the barcode printing service. Your plates have still been created."
    end

    flash[:success] = "#{qc_creator.qcables.count} plates have been created."

    redirect_to :controller=> :lots, :action=>:show, :id=>params[:lot_id]
  end

  private

  def find_lot
    @lot = api.lot.find(params[:lot_id])
  end

  def validate_plate_count
    return true if params[:plate_number].to_i >= 1
    flash[:danger] = "Number of plates created must be one or more."
    redirect_to :back
  end

end
