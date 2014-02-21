##
# Controls the making and destroying of qcables
class QcablesController < ApplicationController

  include BarcodePrinting

  before_filter :find_user, :find_printer, :find_lot
  skip_before_filter :find_printer, :except => [:create]
  skip_before_filter :find_lot, :except => [:create]
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
      flash[:error] = "There was a problem printing your barcodes. Your plates have still been created."
    end

    flash[:success] = "#{qc_creator.qcables.count} plates have been created."

    redirect_to :controller=> :lots, :action=>:show, :id=>params[:lot_id]
  end

  ##
  # This doesn't actually destroy qcables, just flags them as such
  def destroy

    state_change = api.state_change.create!(
      :user => @user.uuid,
      :target => params[:id],
      :reason => params[:reason]
    )

    qcable = api.qcable.find(params[:id])

    flash[:success] = "#{qcable.barcode.prefix}#{qcable.barcode.number} has been destroyed!" if state_change.target_state == 'destroyed'

    # There is no reason we should ever hit this one, but if we do, someone needs to know about it.
    flash[:danger]  = "#{qcable.barcode.prefix}#{qcable.barcode.number} was NOT destroyed! Please contact support, as something has gone wrong." unless state_change.target_state == 'destroyed'

    redirect_to :controller=> :lots, :action=>:show, :id=> qcable.lot.uuid
  end

  private

  def find_lot
    @lot = api.lot.find(params[:lot_id])
  end

end
