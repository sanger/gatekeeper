##
# Used for the json calls
class PlatesController < ApplicationController

  ##
  # Find and show the plate
   def show
     @asset = api.plate.find(params[:id])
     @presenter = Presenter::QcAsset.new(@asset)
     render(:json=>@presenter.output,:root=>true,:status=>:created)
   end

end
