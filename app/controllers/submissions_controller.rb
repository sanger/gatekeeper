# frozen_string_literal: true

##
# Create a submission for the given MX tube
class SubmissionsController < ApplicationController
  before_action :find_user
  before_action :find_asset_from_barcode

  def create
    order = api.order_template.find(Settings.submission_templates.miseq).orders.create!(
      study: Settings.study,
      project: Settings.project,
      assets: [@asset.uuid],
      request_options: Gatekeeper::Application.config.request_options,
      user: @user.uuid
    )

    submission = api.submission.create!(
      orders: [order.uuid],
      user: @user.uuid
    )

    submission.submit!

    render(json: { 'success' => 'Submission created!' }, root: true)
  rescue Sequencescape::Api::ConnectionFactory::Actions::ServerError => e
    render(json: { 'error' => 'Submission Failed. ' + /.+\[([^\]]+)\]/.match(e.message)[1] }, root: true, status: 403)
  rescue Sequencescape::Api::ResourceInvalid => e
    render(json: { 'error' => 'Submission Failed. ' + e.resource.errors.full_messages.join('; ') }, root: true, status: 403)
  end

  private

  def find_asset_from_barcode
    raise UserError::InputError, 'No barcode was provided!' if params[:asset_barcode].nil?
    rescue_no_results("Could not find an asset with the barcode #{params[:asset_barcode]}.") do
      @asset = api.search.find(Settings.searches['Find assets by barcode']).first(barcode: params[:asset_barcode])
    end
  end
end
