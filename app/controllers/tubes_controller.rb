##
# Used for the json calls
class TubesController < ApplicationController

  ##
  # Find and show the plate
   def show
     @asset = api.tube.find(params[:id])
     @presenter = Presenter::QcAsset.new(@asset)
     render(json: @presenter.output,root: true,status: :created)
   end

end
