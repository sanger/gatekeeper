# frozen_string_literal: true

##
# Make QC Decisions
class LotsQcDecisionsController < QcDecisionsController
  before_action :find_user, except: %i[search new]
  before_action :find_lot_presenter, except: [:search]

  ##
  # For rendering a QC Decision
  # On Lot
  def new
    render 'qc_decisions/lots/new'
  end

  ##
  # For making a QC Decision
  # On Lot
  def create
    api.qc_decision.create!(
      user: @user.uuid,
      lot: params[:lot_id],
      decisions: decisions.to_h.map do |uuid, decision|
        { 'qcable' => uuid, 'decision' => decision }
      end
    )
    flash[:success] = 'Qc decision has been updated.'
    redirect_to lot_path(params[:lot_id])
  rescue Sequencescape::Api::ResourceInvalid => e
    message = e.resource.errors.messages.map { |k, v| "#{k.capitalize} #{v.to_sentence.chomp('.')}" }.join('; ') << '.'
    flash[:danger] = "A decision was not made. #{message}"
    redirect_to new_lot_qc_decision_path(params[:lot_id])
    nil
  end

  private

  def decisions
    params[:decisions].permit!.select { |uuid, decision| decision.present? }
  end
end
