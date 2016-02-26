##
# Controls the making and destroying of qcables
class QcablesController < ApplicationController

  include BarcodePrinting

  before_filter :find_user, :find_printer, :find_lot, :validate_plate_count

  ##
  # This action should generally get called through the nested
  # lot/qcables route, which will provide our lot id.
  def create

    # If we have the lot type cached in settings, use that.
    qcable_name = (Settings.lot_types[@lot.lot_type_name]||@lot.lot_type).qcable_name

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
      flash[:danger] = "There was a problem printing your barcodes. Your #{qcable_name.pluralize} have still been created."
    rescue Errno::ECONNREFUSED => exception
      flash[:danger] = "Could not connect to the barcode printing service. Your #{qcable_name.pluralize} have still been created."
    end

    flash[:success] = "#{qc_creator.qcables.count} #{qcable_name.pluralize} have been created."

    redirect_to :controller=> :lots, :action=>:show, :id=>params[:lot_id]
  end

  private

  def find_lot
    @lot = api.lot.find(params[:lot_id])
  end

  def validate_plate_count
    range = Gatekeeper::Application.config.stamp_range
    step  = Gatekeeper::Application.config.stamp_step
    return true if range.cover?(params[:plate_number].to_i) && (params[:plate_number].to_i%step ==0)
    flash[:danger] = "Number of plates created must be a multiple of #{step} between #{range.first} and #{range.last} inclusive"
    redirect_to :back
  end

end
