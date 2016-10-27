##
# For confirming users exist
class UsersController < ApplicationController

  def search
    begin
      swipecard_code = params[:user_swipecard]
      @user = Presenter::User.new(
        api.search.find(Settings.searches['Find user by swipecard code']).first(swipecard_code: swipecard_code)
        )
    rescue Sequencescape::Api::ResourceNotFound
      return render(
        json: Presenter::User.new(nil).output,
        status: 404
        )
    end

    render(json: @user.output)
  end

end
