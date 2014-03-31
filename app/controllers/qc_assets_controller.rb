##
# Create QC Tubes
class QcAssetsController < ApplicationController

  before_filter :find_user, :except => [:new,:search]
  before_filter :find_asset_from_barcode, :only => [:search,:create]

  before_filter :validate_parameters, :only => [:create]

  rescue_from UserError::InputError, :with => :render_error

  def new
  end

  def search
    @presenter = Presenter::QcAsset.new(@asset)
    render(:json=>@presenter.output,:root=>true)
  end

  def create
    begin
      child = QcAssetCreator.new(
        :api      => api,
        :asset    => @asset,
        :user     => @user,
        :purpose  => params[:purpose],
        :sibling  => find_sibling_from_barcode,
        :template => params[:template]
      ).create!
    rescue QcAssetCreator::QcAssetException => exception
      @presenter = Presenter::Error.new(exception)
      render(:json=>@presenter.output,:root=>true,:status=>403)
      return false
    end
    redirect_to(
      :controller => Settings.purposes[params[:purpose]].type.pluralize,
      :id         => child.uuid,
      :action     => :show
    )
  end

  private

  def find_asset_from_barcode
    raise UserError::InputError, "No barcode was provided!" if params[:asset_barcode].nil?
    @asset = find_from_barcode(params[:asset_barcode])
  end

  def find_sibling_from_barcode
    find_from_barcode(params[:sibling]) if params[:sibling].present?
  end

  def find_from_barcode(barcode)
    begin
      return api.search.find(Settings.searches['Find assets by barcode']).first(:barcode => barcode)
    rescue Sequencescape::Api::ResourceNotFound
      return render(
        :json=>{'error'=>"Could not find an asset with the barcode #{params[:asset_barcode]}."},
        :root=>true,
        :status=>404
      )
    end
  end

  def validate_parameters
    raise UserError::InputError, "No plate or tube purpose specified." if params[:purpose].nil?
    raise UserError::InputError, "Unknown plate or tube purpose specified." if Settings.purposes(params[:purpose]).nil?
  end

  def render_error(exception)
    render(:json=>{'error'=>exception.message},:root=>true,:status=>403)
    return false
  end



end
