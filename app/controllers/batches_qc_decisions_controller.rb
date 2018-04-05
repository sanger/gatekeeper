# frozen_string_literal: true

##
# Make QC Decisions
class BatchesQcDecisionsController < QcDecisionsController
  before_filter :find_user, except: %i[search new]
  before_filter :find_lots_presenter, except: %i[search create]
  before_filter :find_lot_presenter, only: :create

  def find_lots_presenter
    @lots_presenter ||= Presenter::LotList.new(params[:batch_id], find_lots_for_batch)
  end

  ##
  # For rendering a QC Decision
  # On Batch
  def new
    render 'qc_decisions/batches/new'
  end

  def create
    api.qc_decision.create!(
      user: @user.uuid,
      lot: params[:lot_id],
      decisions: decisions.map do |uuid, decision|
        { 'qcable' => uuid, 'decision' => decision }
      end
    )
    flash[:success] = 'Qc decision has been updated.'
    respond_to do |format|
      format.json do
        render(json: [{ lot: {
                 uuid: params[:lot_id],
                 decision: params[:decision]
               } }])
      end
    end
  rescue Sequencescape::Api::ResourceInvalid => exception
    message = exception.resource.errors.messages.map { |k, v| "#{k.capitalize} #{v.to_sentence.chomp('.')}" }.join('; ') << '.'
    render json: { error: "A decision was not made to #{params[:decision]} for Lot #{params[:lot_id]}: " + message }
  end

  private

  def decisions
    @lot_presenter.pending_qcable_uuids.map { |uuid| [uuid, params[:decision]] }
  end
end
