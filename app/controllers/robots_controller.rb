##
# For finding of robots by barcode.
class RobotsController < ApplicationController

  def search
    begin
      @robot = Presenter::Robot.new(
        api.search.find(Settings.searches['Find robot by barcode']).first(:barcode=>params[:robot_barcode])
        )
    rescue StandardError => exception
      return render(
        :json => Presenter::Robot.new(nil).output,
        :status => 404
        ) if no_search_result?(exception.message)
      raise exception
    end

    render(:json => @robot.output)
  end

end
