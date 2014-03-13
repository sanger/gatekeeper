##
# Create QC Tubes
class QcAssetsController < ApplicationController

  before_filter :find_user
  skip_before_filter :find_user, :only => [:new,:search]
  before_filter :find_asset_from_barcode
  skip_before_filter :find_asset_from_barcode, :except => [:search]

  before_filter :validate_child_purpose
  skip_before_filter :validate_child_purpose, :except => [:create]

  def new
  end

  def search
    @presenter = Presenter::QcAsset.new(@asset)
    render(:json=>@presenter.output,:root=>true)
  end

  def create

    rescue_no_results("Could not find an asset with the barcode #{params[:sibling]}.") do
      @sibling = api.search.find(
        Settings.searches['Find assets by barcode']).
        first(:barcode => params[:sibling]) unless params[:sibling].nil?
    end
    begin
      child = QcAssetCreator.new(
        :api     => api,
        :asset   => api.asset.find(params[:parent]),
        :user    => @user,
        :purpose => params[:purpose],
        :sibling => @sibling
      ).create!
    rescue QcAssetCreator::QcAssetException => exception
      @presenter = Presenter::Error.new(exception)
      render(:json=>@presenter.output,:root=>true,:status=>403)
      return false
    end
    @presenter = Presenter::QcAsset.new(child)
    render(:json=>@presenter.output,:root=>true,:status=>:created)
  end

  private

  def find_asset_from_barcode
    raise UserError::InputError, "No barcode was provided!" if params[:asset_barcode].nil?
    rescue_no_results("Could not find an asset with the barcode #{params[:asset_barcode]}.") do
      @asset = api.search.find(Settings.searches['Find assets by barcode']).first(:barcode => params[:asset_barcode])
    end
  end

  def validate_child_purpose
    raise UserError::InputError, "No plate or tube purpose specified" if params[:purpose].nil?
    raise UserError::InputError, "Unknown plate or tube purpose specified" if Settings.purposes(params[:purpose]).nil?
  end


end
