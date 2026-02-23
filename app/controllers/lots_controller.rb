# frozen_string_literal: true

##
# Controller to handle viewing and creation of lots
# A lot describes a received batch of material such that
# qc conducted on two or more elements (qcables) of the batch
# can be considered to apply to the whole batch.

class LotsController < ApplicationController
  before_action :find_user, except: %i[show new search]
  before_action :find_lot, only: [:show]

  ##
  # Lot summary page.
  # Provides details of associated QCables and lot metadata
  # Also provides interface for creating additional Qcables
  def show
    @lot_presenter = Presenter::Lot.new(@lot)
  end

  ##
  # Register lot page
  # Collects metadata when creating a new lot
  def new
    @lot_type = Presenter::LotType.new(params[:lot_type], api)
    render :new
  rescue Presenter::LotType::ConfigurationError => e
    @message = "Could not register a lot. #{e.message}"
    render 'pages/error', status: :not_found
  end

  ##
  # Register lot action
  # Create action for lot. Registers lot metadata
  # We convert the date into the big endian format to avoid ambiguity
  def create
    # Find the template being used to create this lot
    # If we can't find it, raise an error
    # This is required because Lots have a polymorphic association to templates
    # And json api resources can't handle that automatically
    begin
      template_resource = "Sequencescape::Api::V2::#{params[:template_class]}".constantize
      template = template_resource.find(uuid: params[:template]).first
    rescue StandardError => e
      Rails.logger.error "Error creating lot: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      flash[:danger] = "Could not find template with class #{params[:template_class]} or uuid #{params[:template]}."
      redirect_to new_lot_path
      return
    end

    lot = Sequencescape::Api::V2::Lot.new(
      user_uuid: @user.uuid,
      lot_number: params[:lot_number],
      lot_type_uuid: params[:lot_type_uuid],
      template_type: params[:template_class],
      template_id: template.id,
      received_at: Date.strptime(params[:received_at], '%d/%m/%Y').strftime('%Y-%m-%d')
    )
    begin
      result = lot.save

      # Result is false if, for instance, server-side validation fails e.g. missing user.
      if !result || lot.errors.any?
        message = 'There was a problem creating the lot in Sequencescape.'
        message += " #{lot.errors.full_messages.join(', ')}" if lot.errors.any?
        Rails.logger.error "Error creating lots: #{message}"
        flash[:danger] = message
        redirect_to new_lot_path
        return
      end

      flash[:success] = "Created lot #{lot.lot_number}"
      redirect_to lot_path(lot.uuid)
    rescue StandardError => e
      # Throws an exception, for instance, if Sequencescape returns a 500 error.
      Rails.logger.error "Error creating lot: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      flash[:danger] = 'There was a problem creating the lot in Sequencescape.'

      redirect_to new_lot_path
    end
  end

  ##
  # Finds a lot by lot number, and either redirects to the appropriate page
  # or displays a choice if there are multiple results
  def search
    raise UserError::InputError, 'Please use the find lots by lot number feature to find specific lots.' if params[:lot_number].nil?

    @found_lots = Sequencescape::Api::V2::Lot.find(lot_number: params[:lot_number])

    raise UserError::InputError, "Could not find a lot with the lot_number #{params[:lot_number]}." if @found_lots.empty?

    return redirect_to lot_path(@found_lots.first.uuid) if @found_lots.count <= 1

    @lots = @found_lots.map { |lot| Presenter::Lot.new(lot) }

    render :search, status: :multiple_choices
  end

  private

  def find_lot
    @lot = Sequencescape::Api::V2::Lot.includes(:lot_type, :qcables).where(uuid: params[:id]).first

    return if @lot.present?

    @message = "Could not find lot with uuid: #{params[:id]}"
    render 'pages/error', status: :not_found
  end
end
