# frozen_string_literal: true

##
# Create QC Tubes

class QcAssetsController < ApplicationController
  before_filter :find_user, except: %i[new search]
  before_filter :find_asset_from_barcode, only: %i[search create]
  before_filter :find_sibling_from_barcode, only: [:create]
  before_filter :find_sibling2_from_barcode, only: [:create]

  before_filter :validate_parameters, only: [:create]

  rescue_from UserError::InputError, with: :render_error

  def new; end

  def search
    @presenter = Presenter::QcAsset.new(@asset)
    render(json: @presenter.output, root: true)
  end

  def tag2_tubes
    return nil unless params[:tag2_tube]
    params[:tag2_tube].reject { |index, tube| tube[:barcode].blank? }
  end

  def create
    begin
      child = QcAssetCreator.new(
        api: api,
        asset: @asset,
        user: @user,
        purpose: params[:purpose],
        sibling: @sibling,
        sibling2: @sibling2,
        template: params[:template],
        tag2_tubes: tag2_tubes
      ).create!
    rescue QcAssetCreator::QcAssetException => exception
      @presenter = Presenter::Error.new(exception)
      render(json: @presenter.output, root: true, status: 403)
      return false
    end
    redirect_to(
      controller: type_controller,
      id: child.uuid,
      action: :show
    )
  end

  private

  def type_controller
    Settings.purposes.fetch(params[:purpose], Settings.default_purpose).type.pluralize
  end

  def find_asset_from_barcode
    raise UserError::InputError, 'No barcode was provided!' if params[:asset_barcode].nil?
    @asset = find_from_barcode(params[:asset_barcode])
  end

  def find_sibling_from_barcode
    @sibling = find_from_barcode(params[:sibling]) if params[:sibling].present?
  end

  def find_sibling2_from_barcode
    @sibling2 = find_from_barcode(params[:sibling2]) if params[:sibling2].present?
  end

  def find_from_barcode(barcode)
    return api.search.find(Settings.searches['Find assets by barcode']).first(barcode: barcode)
  rescue Sequencescape::Api::ResourceNotFound
    return render(
      json: { 'error' => "Could not find an asset with the barcode #{barcode}." },
      root: true,
      status: 404
    )
  end

  def validate_parameters
    raise UserError::InputError, 'No plate or tube purpose specified.' if params[:purpose].nil?
    raise UserError::InputError, 'Unknown plate or tube purpose specified.' if Settings.purposes(params[:purpose]).nil?
  end

  def render_error(exception)
    render(json: { 'error' => exception.message }, root: true, status: 403)
    return false
  end
end
