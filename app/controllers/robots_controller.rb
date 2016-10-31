##
# For finding of robots by barcode.
class RobotsController < ApplicationController

  def search
    begin
      @robot = Presenter::Robot.new(
        api.search.find(Settings.searches['Find robot by barcode']).first(barcode: params[:robot_barcode])
        )
    rescue Sequencescape::Api::ResourceNotFound
      return render(
        json: Presenter::Robot.new(nil).output,
        status: 404
        )
    end

    render(json: @robot.output)
  end

end
