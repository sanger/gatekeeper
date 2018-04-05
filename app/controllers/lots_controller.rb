# frozen_string_literal: true

##
# Controller to handle viewing and creation of lots
# A lot describes a received batch of material such that
# qc conducted on two or more elements (qcables) of the batch
# can be considered to apply to the whole batch.

class LotsController < ApplicationController
  before_filter :find_user, except: %i[show new search]
  before_filter :find_lot, only: [:show]

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
  rescue Presenter::LotType::ConfigurationError => exception
    @message = "Could not register a lot. #{exception.message}"
    render 'pages/error', status: 404
  end

  ##
  # Register lot action
  # Create action for lot. Registers lot metadata
  # We convert the date into the big endian format to avoid ambiguity
  def create
    @lot = api.lot_type.find(params[:lot_type]).lots.create!(
      user: @user.uuid,
      lot_number: params[:lot_number],
      template: params[:template],
      received_at: Date.strptime(params[:received_at], '%d/%m/%Y').strftime('%Y-%m-%d')
    )
    flash[:success] = "Created lot #{@lot.lot_number}"

    redirect_to lot_path(@lot)
  rescue Sequencescape::Api::ResourceInvalid => exception
    flash[:danger] = "#{exception.resource.errors.full_messages.join('; ')}."
    redirect_to new_lot_path
  end

  ##
  # Finds a lot by lot number, and either redirects to the appropriate page
  # or displays a choice if there are multiple results
  def search
    raise UserError::InputError, 'Please use the find lots by lot number feature to find specific lots.' if params[:lot_number].nil?
    @found_lots = api.search.find(Settings.searches['Find lot by lot number']).all(Gatekeeper::Lot, lot_number: params[:lot_number])

    raise UserError::InputError, "Could not find a lot with the lot_number #{params[:lot_number]}." if @found_lots.empty?

    return redirect_to lot_path(@found_lots.first) if @found_lots.count <= 1

    @lots = @found_lots.map { |lot| Presenter::Lot.new(lot) }

    render :search, status: 300
  end

  private

  def find_lot
    @lot = api.lot.find(params[:id])
  rescue Sequencescape::Api::ResourceNotFound => exception
    @message = "Could not find lot with uuid: #{params[:id]}"
    render 'pages/error', status: 404
  end
end
