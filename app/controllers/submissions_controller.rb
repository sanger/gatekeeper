##
# Create a submission for the given MX tube
class SubmissionsController < ApplicationController

  before_filter :find_user
  before_filter :find_asset_from_barcode

  def create
    order = api.order_template.find(Settings.submission_templates.miseq).orders.create!(
      :study => Settings.study,
      :project => Settings.project,
      :assets => [@asset.uuid],
      :request_options => Gatekeeper::Application.config.request_options,
      :user => @user.uuid
    )

    submission = api.submission.create!(
      :orders => [order.uuid],
      :user => @user.uuid
    )

    submission.submit!

    render(:json=>{'success'=>'Submission created!'},:root=>true)
  end

  private

  def find_asset_from_barcode
    raise UserError::InputError, "No barcode was provided!" if params[:asset_barcode].nil?
    rescue_no_results("Could not find an asset with the barcode #{params[:asset_barcode]}.") do
      @asset = api.search.find(Settings.searches['Find assets by barcode']).first(:barcode => params[:asset_barcode])
    end
  end
end
