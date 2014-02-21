##
# Controller to handle viewing and creation of lots
# A lot describes a received batch of material such that
# qc conducted on two or more elements (qcables) of the batch
# can be considered to apply to the whole batch.

class LotsController < ApplicationController

  before_filter :find_user
  skip_before_action :find_user, :except => [:create]

  before_filter :find_lot
  skip_before_action :find_lot, :except => [:show]

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
    begin
      @lot_type = Presenter::LotType.new(params[:lot_type])
      render :new
    rescue Presenter::LotType::ConfigurationError => exception
      @message  = "Could not register a lot. #{exception.message}"
      render 'pages/error', :status => 404
    end
  end

  ##
  # Register lot action
  # Create action for lot. Registers lot metadata
  # We convert the date into the big endian format to avoid ambiguity
  def create
    @lot = api.lot_type.find(params[:lot_type]).lots.create!(
      :user        => @user.uuid,
      :lot_number  => params[:lot_number],
      :template    => params[:template],
      :received_at => Date.strptime(params[:received_at], '%d/%m/%Y').strftime('%Y-%m-%d')
    )
    flash[:success] = "Created lot #{@lot.lot_number}"

    redirect_to lot_url(@lot)
  end

  private

  def find_lot
    begin
      @lot = api.lot.find(params[:id])
    rescue StandardError => exception
      raise exception unless exception.message.include?('UUID does not exist')
      @message  = "Could not find lot with uuid: #{params[:id]}"
      render 'pages/error', :status => 404
    end
  end

end
