##
# Make QC Decisions
class BatchesQcDecisionsController < QcDecisionsController

  before_filter :find_user, :except=>[:search,:new]
  before_filter :find_lots_presenter, :except => [:search]

  def find_lots_presenter
    @lots_presenter ||= Presenter::LotList.new(params[:batch_id], find_lots_for_batch)
  end

  ##
  # For rendering a QC Decision
  # On Batch
  def new
    render 'qc_decisions/batches/new'
  end

  def decisions
    @lots_presenter.presenter_for_lot_uuid(params[:lot_id]).pending_qcable_uuids.map do |uuid|
      [uuid, params[:decision]]
    end
  end

  def create
    begin
      api.qc_decision.create!(
        :user => @user.uuid,
        :lot  => params[:lot_id],
        :decisions => decisions.map do |uuid,decision|
          {'qcable'=>uuid, 'decision' => decision }
        end
      )
      flash[:success] = "Qc decision has been updated."

      respond_to do |format|
        format.json{
          render :json => [{:lot => {
            :uuid => params[:lot_id],
            :decision => params[:decision]
            }}]
        }
      end
    rescue Sequencescape::Api::ResourceInvalid => exception
      message = exception.message
      render :json => {:error => "Sequencescape message: On decision #{params[:decision]} for Lot #{params[:lot_id]}: " + message}
    end
  end

end
