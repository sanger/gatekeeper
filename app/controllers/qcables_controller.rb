# frozen_string_literal: true

##
# Controls the making and destroying of qcables
class QcablesController < ApplicationController
  include BarcodePrinting

  before_action :find_user, :find_lot
  before_action :find_printer, only: [:create]

  ##
  # This action should generally get called through the nested
  # lot/qcables route, which will provide our lot id.
  def create
    qc_creator = api.qcable_creator.create!(
      user: @user.uuid,
      lot: @lot.uuid,
      count: params[:plate_number].to_i
    )

    labels = qc_creator.qcables.map do |q|
      BarcodeSheet::Label.new(prefix: q.barcode.prefix, number: q.barcode.number, barcode: q.barcode.machine, lot: @lot.lot_number, template: @lot.template_name)
    end

    begin
      BarcodeSheet.new(@printer, labels).print!
    rescue BarcodeSheet::PrintError => e
      flash[:danger] = "There was a problem printing your barcodes. Your #{qcable_name.pluralize} have still been created. #{e.message}"
    rescue Errno::ECONNREFUSED
      flash[:danger] = "Could not connect to the barcode printing service. Your #{qcable_name.pluralize} have still been created."
    end

    flash[:success] = "#{qc_creator.qcables.count} #{qcable_name.pluralize} have been created."

    redirect_to controller: :lots, action: :show, id: params[:lot_id]
  rescue Net::ReadTimeout
    flash[:danger] = "Things are taking a bit longer than expected; your #{qcable_name.pluralize} are still being created in the background. Please check back later."
    redirect_to controller: :lots, action: :show, id: params[:lot_id]
  end

  def upload
    qc_creator = api.qcable_creator.create!(
      user: @user.uuid,
      lot: @lot.uuid,
      barcodes: PlateUploader.new(params[:upload]).payload
    )

    flash[:success] = "#{qc_creator.qcables.count} #{qcable_name.pluralize} have been created."

    redirect_to controller: :lots, action: :show, id: params[:lot_id]
  rescue Net::ReadTimeout
    flash[:danger] = "Things are taking a bit longer than expected; your #{qcable_name.pluralize} are still being created in the background. Please check back later."
    redirect_to controller: :lots, action: :show, id: params[:lot_id]
  end

  private

  def qcable_name
    # If we have the lot type cached in settings, use that.
    (Settings.lot_types[@lot.lot_type_name] || @lot.lot_type).qcable_name
  end

  def find_lot
    @lot = api.lot.find(params[:lot_id])
  end

  def validate_plate_count
    range = Gatekeeper::Application.config.stamp_range
    step  = Gatekeeper::Application.config.stamp_step
    return true if range.cover?(params[:plate_number].to_i) && (params[:plate_number].to_i % step == 0)
    flash[:danger] = "Number of plates created must be a multiple of #{step} between #{range.first} and #{range.last} inclusive"
    redirect_back fallback_location: lots_path
  end
end
