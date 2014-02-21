##
# Controls the making and destroying of qcables
class QcablesController < ApplicationController

  before_filter :find_user

  ##
  # This action should generally get called through the nested
  # lot/qcables route, which will provide our lot id.
  def create

    qc_creator = api.qcable_creator.create!(
      :user => @user.uuid,
      :lot  => params[:lot_id],
      :count => params[:plate_number].to_i
    )

    flash[:success] = "#{qc_creator.qcables.count} plates have been created."

    redirect_to :controller=> :lots, :action=>:show, :id=>params[:lot_id]
  end

end
