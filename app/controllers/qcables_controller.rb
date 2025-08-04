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
  #
  # pre stamped plates - _create_children
  def create
    # Make a qcable creator with the supplied count, under an existing lot, in SS.
    qcable_creator = create_qcable_creator
    
    print_labels(qcable_creator) if qcable_creator

    redirect_to controller: :lots, action: :show, id: params[:lot_id]
  rescue Net::ReadTimeout
    flash[:danger] = "Things are taking a bit longer than expected; your #{qcable_name.pluralize} are still being created in the background. Please check back later."
    redirect_to controller: :lots, action: :show, id: params[:lot_id]
  end

  def create_qcable_creator
    # Set the relationships using assignment rather than passing them in as params,
    # because json_api_client gem was interpreting the params incorrectly as a hash of attributes.
    qc_creator = Sequencescape::Api::V2::QcableCreator.new(count: params[:plate_number].to_i)
    qc_creator.user = Sequencescape::Api::V2::User.where(uuid: @user.id).first
    qc_creator.lot = Sequencescape::Api::V2::Lot.where(uuid: @lot.id).first

    begin
      result = qc_creator.save 

      # Result is false if, for instance, server-side validation fails e.g. missing user or lot.
      if !result || qc_creator.errors.any? 
        message = "There was a problem creating plates in Sequencescape."
        if qc_creator.errors.any?
          message += " #{qc_creator.errors.full_messages.join(', ')}"
        end
        Rails.logger.error "Error creating qcables: #{message}"
        flash[:danger] = message
        return
      end
    rescue => e
      # Throws an exception, for instance, if Sequencescape returns a 500 error.
      Rails.logger.error "Error creating qcables: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      flash[:danger] = "There was a problem creating plates in Sequencescape."
      return
    end 

    qc_creator
  end

  def print_labels(qc_creator)
    # TODO: check if qc_creator / qcables relationship works

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
  end

  # Create IDT tag plate hits here
  def upload
    # Make a qcable creator with the supplied barcodes, under an existing lot, in SS.
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
end
