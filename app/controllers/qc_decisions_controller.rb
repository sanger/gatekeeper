##
# Make QC Decisions
class QcDecisionsController < ApplicationController

  before_filter :find_user, :except=>[:search,:new]

  ##
  # Finds a lot for qcing on the basis of batch id
  def search
    rescue_no_results("Could not find an appropriate lot for batch #{params[:batch_id]}.") do
      lot = api.search.find(Settings.searches['Find lot by batch id']).first(:batch_id => params[:batch_id])
      redirect_to new_lot_qc_decision_path(lot.uuid)
    end
  end

  ##
  # For rendering a QC Decision
  # On Lot
  def new
    @presenter = Presenter::Lot.new(api.lot.find(params[:lot_id]))
  end

  ##
  # For making a QC Decision
  # On Lot
  def create
    begin
      api.qc_decision.create!(
        :user => @user.uuid,
        :lot  => params[:lot_id],
        :decisions => params[:decisions].map do |uuid,decision|
          {'qcable'=>uuid, 'decision' => decision }
        end
      )
      flash[:success] = "Qc decision has been updated."
      return redirect_to lot_path(params[:lot_id])
    rescue Sequencescape::Api::ResourceInvalid => exception
      message = exception.resource.errors.messages.map {|k,v| "#{k.capitalize} #{v.to_sentence.chomp('.')}"}.join('; ')<<'.'
      flash[:danger] = "A decision was not made. #{message}"
      redirect_to new_lot_qc_decision_path(params[:lot_id])
      return
    end
  end
end
